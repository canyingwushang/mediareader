//
//  MRAppUtil.h
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRAppDelegate;
@class MRViewController;

MRAppDelegate* getAppDelegate();
MRViewController* getBaseController();

@interface MRAppUtil : NSObject

+ (NSString *) getPersistFilePath;
+ (NSString *) getDocsPath;
+ (NSString *) getCatalogInDocs;
+ (NSString *) getVideoPath:(NSUInteger )pid;
+ (NSString *) getHTMLPath:(NSUInteger )pid;
+ (NSString *) getCommonPath;
@end
