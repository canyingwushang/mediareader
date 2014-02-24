//
//  MRCatalogItem.m
//  MediaReader
//
//  Created by jinbo he on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRCatalogItem.h"

@implementation MRCatalogItem

@synthesize docpath;
@synthesize videopath;
@synthesize pid;
@synthesize indexname;
@synthesize name;
@synthesize pages;
@synthesize imageindex;
@synthesize imagesindex;

- (void) dealloc
{
    self.name = nil;
    self.docpath = nil;
    self.videopath = nil;
    self.indexname = nil;
    self.imagesindex = nil;
    [super dealloc];
}

@end
