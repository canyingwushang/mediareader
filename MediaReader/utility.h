#ifndef _UTILITY_H_
#define _UTILITY_H_

#include <stdint.h>
#include <stddef.h>

struct sockaddr;

int get_server(const char* host_name, uint16_t port, struct sockaddr* server);

int get_connection(const struct sockaddr* server);

int read_bytes(int sock, char* buf, size_t buf_size);

int read_fixed_bytes(int sock, char* buf, size_t buf_size);

int write_bytes(int sock, const char* buf, size_t buf_size);

int write_all_bytes(int sock, const char* buf, size_t buf_size);

#endif //_UTILITY_H_
