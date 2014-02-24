//
//  MRCatalogItem.h
//  MediaReader
//
//  Created by jinbo he on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCatalogItem : NSObject
{
    NSUInteger  pid;
    NSString * indexname;
    NSString * name;
    NSString * docpath;
    NSString * videopath;
    NSUInteger pages;
    NSUInteger imageindex;
    NSMutableArray * imagesindex;
}

@property (assign, nonatomic) NSUInteger pid;
@property (retain, nonatomic) NSString * indexname;
@property (retain, nonatomic) NSString * name;
@property (retain, nonatomic) NSString * docpath;
@property (retain, nonatomic) NSString * videopath;
@property (assign, nonatomic) NSUInteger pages;
@property (assign, nonatomic) NSUInteger imageindex;
@property (retain, nonatomic) NSMutableArray * imagesindex;

@end
