#include <string.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/evp.h>
#include "common.h"
#include "http.h"
#include "review.h"


static const int RSA_KEY_BIT = 1024;
const int MAX_SYMMETRIC_KEY_LEN = 64;
const int MAX_SYMMETRIC_IV_LEN = 64;
const int MAX_COOKIE_LEN = 128;

static const int MAX_CONTENT_LEN_LEN = 8;
static const int MAX_ID_LEN = 40;
static const int MAX_REVIEW_LEN = 2048;


static const int MAX_HTTP_HEADER_COUNT = 16;

static char* get_rsa_public_key(RSA* rsa, int* key_len)
{
    EVP_PKEY* evp_pkey = EVP_PKEY_new();
    if(evp_pkey == NULL){
        return NULL;
    }

    EVP_PKEY_set1_RSA(evp_pkey, rsa);
    
    BIO* bio = BIO_new(BIO_s_mem());
    if(bio == NULL){
        goto bio_new_failed;
    }

    if(PEM_write_bio_PUBKEY(bio, evp_pkey) == 0){
        goto pem_write_bio_pubkey_failed;
    }

    const int INITIAL_SIZE = 64;
    int count = INITIAL_SIZE;
    char* buffer = malloc(count);
    if(buffer == NULL){
        goto bio_read_failed;
    }

    int total_read = 0;
    char* p = buffer;
    while(1){
        int byte_read = BIO_read(bio, p, count - total_read);
        if(byte_read < 0){
            goto bio_read_failed;
        }else if(byte_read < count - total_read){
            total_read += byte_read;
            break;
        }else{
            total_read += byte_read;
            count *= 2;
            char* temp = realloc(buffer, count);
            if(temp == NULL){
                goto bio_read_failed;
            }

            buffer = temp;
            p = buffer + total_read;
        }
    }

    *key_len = total_read;
    return buffer;


bio_read_failed:
    free(buffer);
pem_write_bio_pubkey_failed:
    BIO_free(bio);
bio_new_failed:
    EVP_PKEY_free(evp_pkey);

    return NULL;
}

static int private_decrypt(const unsigned char* ciphertext,
                           int ciphertext_len,
                           RSA* rsa,
                           unsigned char* plaintext,
                           int* plaintext_len)
{
    *plaintext_len = RSA_private_decrypt(ciphertext_len, ciphertext, plaintext, rsa, RSA_PKCS1_PADDING);
    if(*plaintext_len == -1){
        fprintf(stderr, "private decrypt failed: %s\n", ERR_error_string(ERR_get_error(), NULL));
        return -1;
    }

    return 0;
}

static int symmetric_encrypt(const unsigned char* key,
                             int key_len,
                             const unsigned char* iv,
                             int iv_len,    
                             const unsigned char* plaintext,
                             int plaintext_len,
                             unsigned char** ciphertext,
                             int* ciphertext_len)
{
    EVP_add_cipher(EVP_aes_256_cbc());

    EVP_CIPHER_CTX ctx;
    EVP_EncryptInit(&ctx, EVP_aes_256_cbc(), NULL, NULL);
    EVP_CIPHER_CTX_set_key_length(&ctx, key_len);
    EVP_EncryptInit(&ctx, NULL, key, iv);

    *ciphertext = malloc(plaintext_len + EVP_CIPHER_CTX_block_size(&ctx));
    if(*ciphertext == NULL){
        return -1;
    }
    
    int part_len = 0;
    if(EVP_EncryptUpdate(&ctx, *ciphertext, &part_len, plaintext, plaintext_len) != 1){
        goto failed;
    }
    *ciphertext_len = part_len;
    if(EVP_EncryptFinal(&ctx, *ciphertext + part_len, &part_len) != 1){
        goto failed;
    }
    *ciphertext_len += part_len;

    return 0;

failed:
    free(*ciphertext);
    *ciphertext = NULL;
    *ciphertext_len = 0;

    return -1;
}

static int symmetric_decrypt(const unsigned char* key,
                             int key_len,
                             const unsigned char* iv,
                             int iv_len,    
                             const unsigned char* ciphertext,
                             int ciphertext_len,
                             unsigned char** plaintext,
                             int* plaintext_len)
{
    EVP_add_cipher(EVP_aes_256_cbc());
    
    EVP_CIPHER_CTX ctx;
    EVP_DecryptInit(&ctx, EVP_aes_256_cbc(), NULL, NULL);
    EVP_CIPHER_CTX_set_key_length(&ctx, key_len);
    EVP_DecryptInit(&ctx, NULL, key, iv);

    *plaintext = malloc(ciphertext_len + EVP_CIPHER_CTX_block_size(&ctx));
    if(*plaintext == NULL){
        return -1;
    }

    int part_len = 0;
    if(EVP_DecryptUpdate(&ctx, *plaintext, &part_len, ciphertext, ciphertext_len) != 1){
        goto failed;
    }
    *plaintext_len = part_len;
    if(EVP_DecryptFinal(&ctx, *plaintext + part_len, &part_len) != 1){
        goto failed;
    }

    *plaintext_len += part_len;

    return 0;

failed:
    free(*plaintext);
    *plaintext = NULL;
    *plaintext_len = 0;
    
    return -1;
}

static int extract_key_iv(const unsigned char* msg,
                          int msg_len,
                          unsigned char* key,
                          int key_buf_len,
                          int *key_len,
                          unsigned char* iv,
                          int iv_buf_len,
                          int* iv_len)
{
    *key_len = 0;
    *iv_len = 0;
    
    const unsigned char* p = msg;
    int len = msg_len;
    const int key_prefix_len = sizeof("key=") - 1;
    const int iv_prefix_len = sizeof("iv=") - 1;
    while(len > 0){
        if((len > key_prefix_len) && (strncmp((const char*)p, "key=", key_prefix_len) == 0)){
            int i = 0;
            while((i < len) && (p[i] != '&')){
                ++i;
            }

            if(i - key_prefix_len > key_buf_len){
                fprintf(stderr, "invalid key len: %i\n", i);
                return -1;
            }

            memcpy(key, p + key_prefix_len, i - key_prefix_len);            
            *key_len = i - key_prefix_len;
            p += i + 1;
            len -= i + 1;
        }else if((len > iv_prefix_len) && (strncmp((const char*)p, "iv=", iv_prefix_len) == 0)){
            int i = 0;
            while((i < len) && (p[i] != '&')){
                ++i;
            }

            if(i - iv_prefix_len > iv_buf_len){
                fprintf(stderr, "invalid iv len: %i\n", i);
                return -1;
            }
            
            memcpy(iv, p + iv_prefix_len, i - iv_prefix_len);
            *iv_len = i - iv_prefix_len;
            p += i + 1;
            len -= i + 1;
        }else{
            fwrite(msg, msg_len, 1, stderr);
            putchar('\n');
            return -1;
        }
    }

    return 0;
}

static int get_cookie(const struct http_header* headers, int header_count, char* cookie, int cookie_buf_len)
{
    const char* set_cookie = get_header_value(headers, header_count, "Set-Cookie");
    if(set_cookie == NULL){
        fprintf(stderr, "no Set-Cookie header found\n");
        return -1;
    }

    const char* p = set_cookie;
    while((*p) && (*p != ';')){
        ++p;
    }

    const int len = p - set_cookie;
    if(len >= cookie_buf_len){
        fprintf(stderr, "cookie_buf_len(%i) is too small, need %i\n", cookie_buf_len, len + 1);
        return -1;
    }

    const char* q = set_cookie;
    char* r = cookie;
    while(q < p){
        *r++ = *q++;
    }

    *r = '\0';

    return 0;
}

int get_cookie_key_iv(int sock,
                      char* cookie,
                      int cookie_buf_len,
                      unsigned char* key,
                      int key_buf_len,
                      int* key_len,
                      unsigned char* iv,
                      int iv_buf_len,
                      int* iv_len)
{
    int error = -1;
    
    const char* uri = "/init.php";

    int status_code = 0;
    struct http_header response_headers[MAX_HTTP_HEADER_COUNT];
    memset(response_headers, 0, sizeof(response_headers));
    char* msg = NULL;
    int msg_len = 0;

    RSA* rsa = RSA_generate_key(RSA_KEY_BIT, RSA_3, NULL, NULL);
    if(rsa == NULL){
        fprintf(stderr, "RSA_generate_key failed: %s\n", ERR_error_string(ERR_get_error(), NULL));
        return -1;
    }

    int public_key_len = 0;
    const char* public_key = get_rsa_public_key(rsa, &public_key_len);
    char content_len[MAX_CONTENT_LEN_LEN];
    snprintf(content_len, sizeof(content_len), "%i", public_key_len);
    struct http_header request_headers[] =
        {
            {"Host", HOST_NAME},
            {"Content-Length", content_len},
            {"Connection", "Keep-Alive"},
            {NULL, NULL}
        };
    
    unsigned char plaintext[RSA_size(rsa)];
    int plaintext_len = 0;

    if(public_key == NULL){
        goto free_rsa;
    }

    if(send_http_request(sock, HTTP_REQUEST_POST, HTTP_VERSION, uri, request_headers, public_key, public_key_len) != 0){
        fprintf(stderr, "send_http_request failed\n");
        goto free_public_key;
    }

    if(get_http_response(sock, &status_code, response_headers, MAX_HTTP_HEADER_COUNT, &msg, &msg_len) != 0){
        goto free_public_key;
    }

    if(private_decrypt((unsigned char*)msg, msg_len, rsa, plaintext, &plaintext_len) != 0){
        goto free_public_key;
    }

    if(get_cookie(response_headers, MAX_HTTP_HEADER_COUNT, cookie, cookie_buf_len) != 0){
        fprintf(stderr, "get_cookie failed\n");
        goto free_public_key;
    }

    if(extract_key_iv(plaintext, plaintext_len, key, key_buf_len, key_len, iv, iv_buf_len, iv_len) != 0){
        fprintf(stderr, "extract_key_iv failed\n");
        goto free_public_key;
    }


    free_header(response_headers, MAX_HTTP_HEADER_COUNT);
    free(msg);
    error = 0;

free_public_key:
    free((void*)public_key);
    
free_rsa:
    RSA_free(rsa);
    
    return error;    
}

static int inline base64_len(int len)
{
    return (len + 2) / 3 * 4;
}

static int inline encode_len(int id_len, int review_len)
{
    return strlen("id=") + base64_len(id_len) + strlen("&") + strlen("review=") + base64_len(review_len);
}

static int inline encode(const char* id, int id_len, const char* review, int review_len, unsigned char* out, int out_len)
{
    if(out_len < encode_len(id_len, review_len)){
        return -1;
    }

    unsigned char* p = out;
    memcpy(p, "id=", strlen("id="));
    p += strlen("id=");
    EVP_EncodeBlock(p, (unsigned char*)id, id_len);
    p += base64_len(id_len);
    *p++ = '&';
    memcpy(p, "review=", strlen("review="));
    p += strlen("review=");
    EVP_EncodeBlock(p, (unsigned char*)review, review_len);

    return 0;
}

int commit_review(int sock,
                  const char* id,
                  const char* review,
                  const char* cookie,
                  const unsigned char* key,
                  int key_len,
                  const unsigned char* iv,
                  int iv_len)
{
    const int id_len = strlen(id);
    const int review_len = strlen(review);
    if((id_len <=0 ) || (id_len > MAX_ID_LEN) || (review_len <= 0) || (review_len > MAX_REVIEW_LEN)){
        fprintf(stderr, "id(%i) or review(%i) out of range\n", id_len, review_len);
        return -1;
    }

    const int plaintext_len = encode_len(id_len, review_len);
    unsigned char plaintext[plaintext_len];
    if(encode(id, id_len, review, review_len, plaintext, plaintext_len) != 0){
        fprintf(stderr, "encode failed\n");
        return -1;
    }
    
    unsigned char* ciphertext = NULL;
    int ciphertext_len = 0;
    if(symmetric_encrypt(key, key_len, iv, iv_len, plaintext, plaintext_len, &ciphertext, &ciphertext_len) != 0){
        fprintf(stderr, "symmetric_encrypt failed\n");
        return -1;
    }

    const const char* uri = "/commit.php";
    char content_len[MAX_CONTENT_LEN_LEN];
    if(snprintf(content_len, sizeof(content_len), "%i", ciphertext_len) >= sizeof(content_len)){
        fprintf(stderr, "ciphertext_len is too long: %i\n", ciphertext_len);
        return -1;
    }
    struct http_header request_headers[] =
    {
        {"Host", HOST_NAME},
        {"Cookie", cookie},
        {"Content-Length", content_len},
        {NULL, NULL}
    };

    const int error = send_http_request(sock, HTTP_REQUEST_POST, HTTP_VERSION, uri, request_headers, (char*)ciphertext, ciphertext_len);
    free(ciphertext);
    if(error != 0){
        fprintf(stderr, "send_http_request failed\n");
        return -1;
    }

    int status_code = 0;
    struct http_header response_headers[MAX_HTTP_HEADER_COUNT];
    memset(response_headers, 0, sizeof(response_headers));
    char* msg = NULL;
    int msg_len = 0;
    if(get_http_response(sock, &status_code, response_headers, MAX_HTTP_HEADER_COUNT, &msg, &msg_len) != 0){
        fprintf(stderr, "get_http_response failed\n");
        return -1;
    }

    free_header(response_headers, MAX_HTTP_HEADER_COUNT);
    
    if(status_code == 200){
        free(msg);
        return 0;
    }else{
        fprintf(stderr, "response status code %i: %s\n", status_code, msg);
        free(msg);
        return -1;
    }
}

int get_review(int sock,
               const char* id,
               char** reviews,
               int* reviews_len,
               const char* cookie,
               const unsigned char* key,
               int key_len,
               const unsigned char* iv,
               int iv_len)

{
    *reviews = NULL;
    *reviews_len = 0;
    
    const int id_len = strlen(id);
    if((id_len <= 0) || (id_len > MAX_ID_LEN)){
        return -1;
    }

    const char* uri = "/review.php";
    char content_len[MAX_CONTENT_LEN_LEN];
    if(snprintf(content_len, sizeof(content_len), "%i", id_len) >= sizeof(content_len)){
        fprintf(stderr, "id_len is too long: %i\n", id_len);
        return -1;
    }
    
    struct http_header request_headers[] =
    {
        {"Host", HOST_NAME},
        {"Cookie", cookie},
        {"Content-Length", content_len},
        {NULL, NULL}
    };

    if(send_http_request(sock, HTTP_REQUEST_POST, HTTP_VERSION, uri, request_headers, id, id_len) != 0){
        fprintf(stderr, "send id failed\n");
        return -1;
    }

    int status_code = 0;
    struct http_header response_headers[MAX_HTTP_HEADER_COUNT];
    memset(response_headers, 0, sizeof(response_headers));
    char* ciphertext = NULL;
    int ciphertext_len = 0;
    if(get_http_response(sock, &status_code, response_headers, MAX_HTTP_HEADER_COUNT, &ciphertext, &ciphertext_len) != 0){
        fprintf(stderr, "get_http_response failed\n");
        return -1;
    }
    free_header(response_headers, MAX_HTTP_HEADER_COUNT);

    int error = -1;
    if(status_code == 200){
        error = symmetric_decrypt(key, key_len, iv, iv_len, (unsigned char*)ciphertext, ciphertext_len, (unsigned char**)reviews, reviews_len);
        if(error != 0){
            fprintf(stderr, "symmetric_decrypt faile\n");
        }
    }else{
        fprintf(stderr, "response status code %i: %s\n", status_code, ciphertext);
    }
    
    free(ciphertext);

    return error;
}

int destroy_session(int sock, const char* cookie)
{
    const char* uri = "/exit.php";    
    struct http_header request_headers[] =
    {
        {"Host", HOST_NAME},
        {"Cookie", cookie},
        {"Content-Length", "0"},
        {NULL, NULL}
    };

    if(send_http_request(sock, HTTP_REQUEST_POST, HTTP_VERSION, uri, request_headers, NULL, 0) != 0){
        fprintf(stderr, "destroy session failed\n");
        return -1;
    }

    return 0;
}
