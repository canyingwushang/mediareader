#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "utility.h"
#include "http.h"


static int MAX_HTTP_HEADER_SIZE = 2048;


static int get_http_request_header(enum HTTP_REQUEST_METHOD method,
                                   const char* version,
                                   const char* uri,
                                   const struct http_header* headers,
                                   char* buffer,
                                   int buffer_size,
                                   int* header_len)
{
    *header_len = 0;

    //fix it.
    const int written = snprintf(buffer, buffer_size, "%s %s HTTP/%s\r\n", (method == HTTP_REQUEST_GET) ? "GET" : "POST", uri, version);
    if(written < 0){
        goto output_error;
    }else if(written >= buffer_size){
        goto no_enough_space;
    }

    int len = written;
    char* p = buffer + written;

    int i = 0;
    while(headers[i].name != NULL){
        const int written = snprintf(p, buffer_size - len, "%s: %s\r\n", headers[i].name, headers[i].value);
        if(written < 0){
            goto output_error;
        }else if(written >= buffer_size - len){
            goto no_enough_space;
        }

        p += written;
        len += written;
        ++i;
    }

    if(buffer_size - len >= 2){
        *p++ = '\r';
        *p = '\n';

        *header_len = len + 2;

        return 0;
    }


no_enough_space:
    fprintf(stderr, "no enough space\n");
    return -1;

output_error:
    fprintf(stderr, "snprintf failed: %s\n", strerror(errno));
    return -1;
}

int send_http_request(int sock,
                      enum HTTP_REQUEST_METHOD method,
                      const char* version,
                      const char* uri,
                      const struct http_header* headers,
                      const char* msg,
                      int msg_len)
{
    char header_buffer[MAX_HTTP_HEADER_SIZE];
    int header_len = 0;
    if(get_http_request_header(method, version, uri, headers, header_buffer, sizeof(header_buffer), &header_len) != 0){
        fprintf(stderr, "get_http_request_header failed\n");
        return -1;
    }

    if(write_all_bytes(sock, header_buffer, header_len) != 0){
        fprintf(stderr, "send header: %s\n", strerror(errno));
        return -1;
    }

    if(write_all_bytes(sock, msg, msg_len) != 0){
        fprintf(stderr, "send msg failed: %s\n", strerror(errno));
        return -1;
    }

    return 0;
}

void free_header(struct http_header* header, int count)
{
    int i = 0;
    while(i < count){
        if(header[i].name){
            free((void*)header[i].name);
        }

        if(header[i].value){
            free((void*)header[i].value);
        }

        ++i;
    }
}

static int parse_http_reponse_header(int sock,
                                     char* buffer,
                                     int buffer_len,
                                     int* status_code,
                                     struct http_header* headers,
                                     int max_header_count,
                                     const char** msg,
                                     int* msg_len)
{
    char* p = buffer;
    char* q = buffer;
    char* end = buffer;
    int len = 0;
    int header_count = 0;

    *status_code = -1;
    *msg = NULL;
    *msg_len = 0;
    
    while(len < buffer_len){
        const int count = read_bytes(sock, end, buffer_len - len);
        if(count < 0){
            fprintf(stderr, "read_bytes failed: %s\n", strerror(errno));
            goto free_header;
        }else if(count == 0){
            fprintf(stderr, "not a complete http response\n");
            goto free_header;
        }

        end += count;
        len += count;

        while(q < end){
            if(*q == '\n'){
                if((q > p) && (*(q - 1) == '\r')){
                    if(q - p == 1){
                        if((*(p - 1) == '\n') && (*(p - 2) == '\0')){
                            *msg = q + 1;
                            *msg_len = len - (*msg - buffer);

                            return 0;
                        }
                    }
                    
                    *(q - 1) = '\0';
                    if(p == buffer){
                        while((*p != ' ') && (*p != '\0')){
                            ++p;
                        }

                        if(*p == '\0'){
                            fprintf(stderr, "No status code found, invalid http response\n");
                            goto free_header;
                        }else{
                            *status_code = atoi(p + 1);
                        }
                    }else{
                        char* r = p;
                        while((*r != ':') && (*r != '\0')){
                            ++r;
                        }

                        if(*r != '\0'){
                            char* name_end = r++;
                            while(isspace(*r)){
                                ++r;
                            }
                            
                            if(*r != '\0'){
                                if(header_count < max_header_count){
                                    *name_end = '\0';
                                    headers[header_count].name = strdup(p);
                                    headers[header_count].value = strdup(r);
                                    ++header_count;
                                }else{
                                    fprintf(stderr, "too much response header\n");
                                    goto free_header;
                                }
                            }
                        }

                        if(*r == '\0'){
                            fprintf(stderr, "Invalid response header: %s\n", p);
                            goto free_header;
                        }
                    }

                    p = q + 1;
                }
            }
            
            ++q;
        }
    }

    fprintf(stderr, "the response header is too long\n");

free_header:
    free_header(headers, max_header_count);

    return -1;
}

const char* get_header_value(const struct http_header* headers, int header_count, const char* name)
{
    int i = 0;
    while(i < header_count){
        if(headers[i].name != NULL){
            if(strcasecmp(headers[i].name, name) == 0){
                return headers[i].value;
            }
        }
        ++i;
    }

    return NULL;
}

int get_http_response(int sock, int* status_code, struct http_header* headers, int max_header_count, char** msg, int* msg_len)
{
    char header_buffer[MAX_HTTP_HEADER_SIZE];
    *status_code = -1;
    memset(headers, 0, max_header_count * sizeof(struct http_header));
    *msg = NULL;
    *msg_len = 0;
    
    const char* tmp_msg = NULL;
    int tmp_msg_len = 0;
    
    if(parse_http_reponse_header(sock,
                                 header_buffer,
                                 sizeof(header_buffer),
                                 status_code,
                                 headers,
                                 max_header_count,
                                 &tmp_msg,
                                 &tmp_msg_len) != 0){
        fprintf(stderr, "parse http response failed\n");
        return -1;
    }

    //print_header(headers, max_header_count);

    const char* content_len = get_header_value(headers, max_header_count, "Content-Length");
    if(content_len == NULL){
        fprintf(stderr, "Content-Length not found\n");
        goto free_header;
    }

    *msg_len = atoi(content_len);
    
    if(*msg_len > 0){
        *msg = malloc(*msg_len);
        if(*msg == NULL){
            fprintf(stderr, "malloc failed: %s\n", strerror(errno));
            goto free_header;
        }

        if(tmp_msg_len > 0){
            memcpy(*msg, tmp_msg, tmp_msg_len);
        }

        if(*msg_len > tmp_msg_len){
            if(read_fixed_bytes(sock, *msg + tmp_msg_len, *msg_len - tmp_msg_len) != -1){
                fprintf(stderr, "read_fixed_bytes failed: %s\n", strerror(errno));
                goto read_failed;
            }
        }
    }

    return 0;

read_failed:
    free(*msg);
    *msg = NULL;
    *msg_len = 0;
    
free_header:
    free_header(headers, max_header_count);
    
    return -1;
}

#ifdef DEBUG
void print_header(const struct http_header* headers, int max_header_count)
{
    int i = 0;
    while(i < max_header_count){
        if(headers[i].name != NULL){
            fprintf(stdout, "%s: %s\n", headers[i].name, headers[i].value);
        }
        ++i;
    }
}
#endif
