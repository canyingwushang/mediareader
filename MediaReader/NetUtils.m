//
//  NetUtils.c
//  TestOpenSSL
//
//  Created by canyingwushang on 12-8-28.
//  Copyright (c) 2012年 张 超. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "NetUtils.h"
#include "common.h"
#include "utility.h"
#include "review.h"
#import "JSONKit.h"

BOOL commitReview(NSString * pid, NSString * review)
{
    const char * cpid = [[pid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] UTF8String];
    const char * creview = [[review stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] UTF8String];
    struct sockaddr server;
    int sock = -1;
    char cookie[MAX_COOKIE_LEN];
    unsigned char key[MAX_SYMMETRIC_KEY_LEN];
    int key_len = 0;
    unsigned char iv[MAX_SYMMETRIC_IV_LEN];
    int iv_len = 0;
    bool res = true;
    if(get_server(HOST_NAME, HOST_PORT, &server) != 0){
        fprintf(stderr, "get_server failed\n");
        goto failed;
    }
    
    sock = get_connection(&server);
    if(sock == -1){
        fprintf(stderr, "get_connection failed\n");
        goto failed;
    }
    
    if(get_cookie_key_iv(sock, cookie, sizeof(cookie), key, sizeof(key), &key_len, iv, sizeof(iv), &iv_len) != 0){
        fprintf(stderr, "get_cookie_key_iv failed\n");
        goto failed;
    }
    
    if(commit_review(sock, cpid, creview, cookie, key, key_len, iv, iv_len) == 0){
        fprintf(stderr, "testing commit_review succeed!\n");
    }
    else{
    failed:
        fprintf(stderr, "testing commit_review failed!\n");
        res = false;
    }
    
    if(destroy_session(sock, cookie) != 0){
        fprintf(stderr, "destroy_session failed\n");
        res = false;
    }
    close(sock);
    return res;
}

NSArray * getReview (NSString *pid, int startnum, int endnum)
{
//    pid = @"100006";
//    startnum = 1;
//    endnum = 3;
    const char * cpid = [[NSString stringWithFormat:@"%@&%d&%d", pid, startnum, endnum] UTF8String];
    struct sockaddr server;
    int sock = -1;
    char cookie[MAX_COOKIE_LEN];
    unsigned char key[MAX_SYMMETRIC_KEY_LEN];
    int key_len = 0;
    unsigned char iv[MAX_SYMMETRIC_IV_LEN];
    int iv_len = 0;
    char* reviews = NULL;
    int reviews_len = 0;
    NSMutableArray * res = nil;
    if(get_server(HOST_NAME, HOST_PORT, &server) != 0){
        fprintf(stderr, "get_server failed\n");
        goto failed;
    }
    
    sock = get_connection(&server);
    if(sock == -1){
        fprintf(stderr, "get_connection failed\n");
        goto failed;
    }
    
    if(get_cookie_key_iv(sock, cookie, sizeof(cookie), key, sizeof(key), &key_len, iv, sizeof(iv), &iv_len) != 0){
        fprintf(stderr, "get_cookie_key_iv failed\n");
        goto failed;
    }
    res = [[[NSMutableArray alloc] init] autorelease];
    if(get_review(sock, cpid, &reviews, &reviews_len, cookie, key, key_len, iv, iv_len) == 0){
        if(reviews_len == 0){
            fprintf(stderr, "no review associated with id %s\n", cpid);
        }
        NSString *tmpDataStr = [[NSString alloc] initWithBytes:reviews length:reviews_len encoding:NSUTF8StringEncoding];
        NSLog(@"%@", tmpDataStr);
        [res addObjectsFromArray:[tmpDataStr objectFromJSONString]];
        fprintf(stderr, "testing get_review succeed!\n");
    }
    else{
    failed:
        fprintf(stderr, "testing get_review failed!\n");
    }
    
    if(destroy_session(sock, cookie) != 0){
        fprintf(stderr, "destroy_session failed\n");
    }
    
    close(sock);
    return res;
}
