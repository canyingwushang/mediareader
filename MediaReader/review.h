#ifndef _REVIEW_H_
#define _REVIEW_H_

extern const int MAX_COOKIE_LEN;
extern const int MAX_SYMMETRIC_KEY_LEN;
extern const  int MAX_SYMMETRIC_IV_LEN;



int get_cookie_key_iv(int sock,
                      char* cookie,
                      int cookie_buf_len,
                      unsigned char* key,
                      int key_buf_len,
                      int* key_len,
                      unsigned char* iv,
                      int iv_buf_len,
                      int* iv_len);

int commit_review(int sock,
                  const char* id,
                  const char* review,
                  const char* cookie,
                  const unsigned char* key,
                  int key_len,
                  const unsigned char* iv,
                  int iv_len);

//The caller should free the buffer '*reviews' point to if succeed.
int get_review(int sock,
               const char* id,
               char** reviews,
               int* reviews_len,
               const char* cookie,
               const unsigned char* key,
               int key_len,
               const unsigned char* iv,
               int iv_len);

int destroy_session(int sock, const char* cookie);

#endif //_REVIEW_H_
