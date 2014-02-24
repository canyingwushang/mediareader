//
//  MRBookMark.h
//  MediaReader
//
//  Created by jinbo he on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRBookMark : NSObject
{
    NSUInteger pid;
    NSUInteger pagenum;
}

@property (nonatomic, assign) NSUInteger pid;
@property (nonatomic, assign) NSUInteger pagenum;

@end
