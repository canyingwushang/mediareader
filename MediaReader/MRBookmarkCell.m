//
//  MRBookmarkCell.m
//  MediaReader
//
//  Created by jinbo he on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRBookmarkCell.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"

@implementation MRBookmarkCell

@synthesize bookMark;
@synthesize delmark;
@synthesize content;

+ (NSString*) cellIdentifier { return @"MRBookmarkCell"; }
+ (NSString*) nibName { return @"MRBookmarkCell"; }
+ (NSInteger) normalRowHeight { return 50.0; }

- (void) dealloc
{
    self.bookMark = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setItemData: (MRBookMark *) _bookmark
{
    self.bookMark = _bookmark;
    title.text = [getAppDelegate().baseController getIndexName:_bookmark.pid];
    [content setTitle:[NSString stringWithFormat:@"第%d页", _bookmark.pagenum] forState:UIControlStateNormal];
}

@end
