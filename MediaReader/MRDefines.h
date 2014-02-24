//
//  MRDefines.h
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef MediaReader_MRDefines_h
#define MediaReader_MRDefines_h

#ifndef DSLog

#ifdef _DEBUG
#define DSLog(...) NSLog(__VA_ARGS__)
#else
#define DSLog(...) /* */
#endif

#endif

#define KSRELEASE(p)				\
do{                                 \
if (nil != p) [p release];		\
p = nil;                        \
}while(0)

/****************************************
 通知宏定义(MRUF+categaory+name)
 ****************************************/
#define MRNotify_AppDidActive       @"applicationDidBecomeActive"
#define MRNotify_AppDidBackGround   @"applicationDidEnterBackground"

/****************************************
 工具函数宏定义(MRUF+categaory+name)
 ****************************************/
//-- 1.NSNotification
//无参
#define MRUFNotifyPostWithNil(n)         [[NSNotificationCenter defaultCenter] postNotificationName:n object:nil]
//带object参
#define MRUFNotifyPostWithObj(n,o)       [[NSNotificationCenter defaultCenter] postNotificationName:n object:o]
//带userinfo参
#define MRUFNotifyPostWithInfo(n,i)      [[NSNotificationCenter defaultCenter] postNotificationName:n object:nil userInfo:i]
//带object和userinfo参
#define MRUFNotifyPostWithBoth(n,o,i)    [[NSNotificationCenter defaultCenter] postNotificationName:n object:o userInfo:i]

//添加观察者
#define MRUFNotifyAddObserver(n,s)       [[NSNotificationCenter defaultCenter] addObserver:self selector:s name:n object:nil]
#define MRUFNotifyAddObserverForObj(obj,s,n) [[NSNotificationCenter defaultCenter] addObserver:obj selector:s name:n object:nil]

//添加字典对象
#define MRUFDicSetObjectSafe(dic,v,k)                 \
do{                                                     \
if (v != nil && k!=nil) [dic setObject:v forKey:k];      \
}while(0)

#endif


//提示的图片
#define kUIShowTipOkImage @"Checkmark.png"
#define kUIShowTipFailImage @"Checkmark_failed.png"

/****************************************
 CatalogJSON
 ****************************************/

#define CATALOGITEMS            @"sections"
#define CATALOGTOTAL            @"count"
#define CATALOGITEM_NAME        @"name"
#define CATALOGITEM_INDEXNAME   @"indexname"
#define CATALOGITEM_ID          @"id"
#define CATALOGITEM_DOC         @"doc"
#define CATALOGITEM_VIDEO       @"video"
#define CATALOGITEM_PAGES       @"pages"
#define CATALOGITEM_IMAGEINDEX  @"imageindex"
#define CATALOGITEM_IMAGESINDEX  @"imagesindex"

