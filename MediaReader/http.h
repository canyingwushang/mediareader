#ifndef _HTTP_H_
#define _HTTP_H_

struct http_header
{
    const char* name;
    const char* value;
};

enum HTTP_REQUEST_METHOD{HTTP_REQUEST_GET, HTTP_REQUEST_POST};


int send_http_request(int sock,
                      enum HTTP_REQUEST_METHOD method,
                      const char* version,
                      const char* uri,
                      const struct http_header* headers,
                      const char* msg,
                      int msg_len);

int get_http_response(int sock,
                      int* status_code,
                      struct http_header* headers,
                      int max_header_count,
                      char** msg,
                      int* msg_len);

const char* get_header_value(const struct http_header* headers, int header_count, const char* name);

void free_header(struct http_header* header, int count);


#ifdef DEBUG
void print_header(const struct http_header* headers, int max_header_count);
#endif //DEBUG

#endif //_HTTP_H_
