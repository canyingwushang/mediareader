//
//  AppSettings.m
//  LiveSpace
//
//  Created by zhujian on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"
#import "PersistHelper.h"
#import "MRDefines.h"

@implementation AppSettings

@synthesize version;
@synthesize lastPid;
@synthesize lastPage;
@synthesize lastPlayBack;

- (void) initialize
{
	[self reset];
}
- (void) reset
{
	self.version = nil;
}
- (void) terminate
{
	self.version = nil;
}
- (void) persistLoad : (NSDictionary*) dictAllSections
{
	// 找到配置项所在的区段
	NSDictionary* dictSection = [dictAllSections objectForKey: SectionOfApplicationSettings];

    PERSIST_LOAD_ITEM_NSInteger (self, lastPage, dictSection, 0);
    PERSIST_LOAD_ITEM_NSInteger (self, lastPlayBack, dictSection, 0);
    PERSIST_LOAD_ITEM_NSInteger (self, lastPid, dictSection, 0);
}

- (void) persistSave : (NSMutableDictionary*) dictAllSections
{
	NSMutableDictionary* dictSection = [[NSMutableDictionary alloc] init];
    
    MRUFDicSetObjectSafe(dictAllSections, dictSection, SectionOfApplicationSettings);

    PERSIST_SAVE_ITEM_NSInteger(self, lastPage, dictSection);
    PERSIST_SAVE_ITEM_NSInteger(self, lastPlayBack, dictSection);
    PERSIST_SAVE_ITEM_NSInteger(self, lastPid, dictSection);
    	
    MRUFDicSetObjectSafe(dictSection,self.version,@"version");	

	[dictSection release];
}
@end
