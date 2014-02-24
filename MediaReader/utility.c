#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include "utility.h"


int get_server(const char* host_name, uint16_t port, struct sockaddr* server)
{
    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    struct addrinfo* addrinfo_list = NULL;
    
    const int error = getaddrinfo(host_name, NULL, &hints, &addrinfo_list);
    if(error != 0){
        fprintf(stderr, "getaddrinfo failed: %s\n", gai_strerror(error));
        return -1;
    }

    *server = *addrinfo_list->ai_addr;
    freeaddrinfo(addrinfo_list);
    //((struct sockaddr_in*)server)->sin_family = AF_INET;
    ((struct sockaddr_in*)server)->sin_port = htons(port);

    return 0;
}

int get_connection(const struct sockaddr* server)
{
    int sock = socket(PF_INET, SOCK_STREAM, 0);
    if(sock == -1){
        fprintf(stderr, "socket failed: %s\n", strerror(errno));
        return -1;
    }

    if(connect(sock, server, sizeof(struct sockaddr_in)) != 0){
    //if(connect(sock, server, sizeof(server)) != 0){
        fprintf(stderr, "connect failed: %s\n", strerror(errno));
        close(sock);
        return -1;
    }

    return sock;
}

int read_bytes(int sock, char* buf, size_t buf_size)
{
    while(1){
        const int bytes = read(sock, buf, buf_size);
        if(bytes >= 0){
            return bytes;
        }else if((errno == EINTR) || (errno == EWOULDBLOCK) || (errno == EAGAIN)){
            continue;
        }else{
            //log_error("read failed: %s\n", strerror(errno));
            return -1;
        }
    }
}

int read_fixed_bytes(int sock, char* buf, size_t buf_size)
{
    size_t count = 0;
    while(1){
        const int len = read_bytes(sock, buf + count, buf_size - count);
        if(len == -1){
            return -1;
        }

        count += len;
        if((len == 0) || (count == buf_size)){
            break;
        }
    }

    return count;
}

int write_bytes(int sock, const char* buf, size_t buf_size)
{
    while(1){
        const int bytes = write(sock, buf, buf_size);
        if(bytes >= 0){
            return bytes;
        }else if((errno == EINTR) || (errno == EWOULDBLOCK) || (errno == EAGAIN)){
            continue;
        }else{
            //log_error("write failed: %s\n", strerror(errno));
            return -1;
        }
    }
}

int write_all_bytes(int sock, const char* buf, size_t buf_size)
{
    const char* p = buf;
    size_t left = buf_size;
    while(left){
        const int write = write_bytes(sock, p, left);
        if(write == -1){
            return -1;
        }else{
            left -= write;
            p += write;
        }
    }

    return 0;
}
