//
//  AppSettings.h
//  LiveSpace
//
//  Created by zhujian on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SectionOfApplicationSettings @"ApplicationSettings"

/* 
 AppSettings里面放置所有界面类的配置项。
*/

@interface AppSettings : NSObject
{
	NSString*		version;
    NSUInteger      lastPid;
    NSUInteger      lastPage;
    NSUInteger      lastPlayBack;
}

@property (retain, nonatomic) NSString * version;
@property (assign, nonatomic) NSUInteger      lastPid;
@property (assign, nonatomic) NSUInteger      lastPage;
@property (assign, nonatomic) NSUInteger      lastPlayBack;

- (void) initialize;
- (void) reset;
- (void) terminate;
- (void) persistLoad : (NSDictionary*) dictAllSections;
- (void) persistSave : (NSMutableDictionary*) dictAllSections;
@end


