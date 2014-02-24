//
//  MRCatalogCell.m
//  MediaReader
//
//  Created by jinbo he on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRCatalogCell.h"

@implementation MRCatalogCell

@synthesize icon;
@synthesize title;
@synthesize subtitle;
@synthesize btnread;
@synthesize btnimages;
@synthesize btnshare;
@synthesize btnvideo;
@synthesize data;
@synthesize division;

+ (NSString*) cellIdentifier { return @"MRCatalogCell"; }
+ (NSString*) nibName { return @"MRCatalogCell"; }
+ (NSInteger) normalRowHeight { return 130; }

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) dealloc{
    self.data = nil;
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setItemData:(MRCatalogItem *)adata
{
    self.data = adata;
    title.text = adata.indexname;
    subtitle.text = adata.name;
}


- (NSInteger) getItemPid:(MRCatalogItem *)adata
{
    self.data=adata;
    return adata.pid;
}
 

@end
