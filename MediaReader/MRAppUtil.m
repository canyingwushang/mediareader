//
//  MRAppUtil.m
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRAppUtil.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "FSUtil.h"

static MRAppDelegate* mediaReader = nil;

MRAppDelegate* getAppDelegate()
{
	if (nil == mediaReader)
	{
		mediaReader = (MRAppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	return mediaReader;
}

MRViewController* getBaseController()
{
	if (nil == mediaReader)
	{
		mediaReader = (MRAppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	return mediaReader.baseController;
}

@implementation MRAppUtil

+ (NSString *) getPersistFilePath
{
    NSArray * libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString* plistPath = [libraryPaths objectAtIndex : 0];
	plistPath = [plistPath stringByAppendingString : @"/application_persist.plist" ];
	return plistPath;
}

+ (NSString *) getDocsPath
{
    NSString * res = [NSString stringWithFormat:@"%@/docs", [[NSBundle mainBundle] bundlePath]];
    DSLog(@"getDocsPath: %@", res);
    return res;
}

+ (NSString *) getCatalogInDocs
{
    NSString * res = [NSString stringWithFormat:@"%@/docs/catalog", [[NSBundle mainBundle] bundlePath]];
    DSLog(@"getCatalogInDocs: %@", res);
    return res;
}

+ (NSString *) getVideoPath:(NSUInteger )pid
{
    NSString * res = [NSString stringWithFormat:@"%@/%d/", [MRAppUtil getDocsPath], pid];
    DSLog(@"getVideoPath: %@", res);
    return res;
}

+ (NSString *) getHTMLPath:(NSUInteger )pid
{
    NSString * res = [NSString stringWithFormat:@"%@/%d/html/", [MRAppUtil getDocsPath], pid];
    DSLog(@"getHTMLPath: %d", pid);
    DSLog(@"getHTMLPath: %@", res);
    return res;
}

+ (NSString *) getCommonPath
{
    NSString * res = [NSString stringWithFormat:@"%@/common", [MRAppUtil getDocsPath]];
    DSLog(@"getCommonPath: %@", res);
    return res;
}

@end