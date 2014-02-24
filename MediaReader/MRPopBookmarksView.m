//
//  MRPopBookmarksView.m
//  MediaReader
//
//  Created by jinbo he on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRPopBookmarksView.h"
#import "MRBookmarkCell.h"
#import "KSUtility.h"

@implementation MRPopBookmarksView

@synthesize bookmarks;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) setData : (NSMutableArray *) array
{
    self.bookmarks = array;
    [bookMarkTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    bookMarkTable.allowsSelection = NO;
    bookMarkTable.delegate = self;
    bookMarkTable.dataSource = self;
    if([array count] == 0){
        emptyTip.hidden = NO;
    }
    else{
        emptyTip.hidden = YES;
    }
    [bookMarkTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellindertifer  = @"cellindertifer";
    MRBookmarkCell * cell = [tableView dequeueReusableCellWithIdentifier:cellindertifer];
    if (nil == cell)
	{
        if(IS_IOS_5_0_OR_GRATER){
            UINib * nib = [UINib nibWithNibName:[MRBookmarkCell nibName] bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:[MRBookmarkCell cellIdentifier]];
            cell = (MRBookmarkCell*)[tableView dequeueReusableCellWithIdentifier : [MRBookmarkCell cellIdentifier]];
        }
        else{
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed : [MRBookmarkCell nibName] owner : tableView options : nil];
            cell = [arr objectAtIndex : 0];
        }
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.delmark addTarget:self action:@selector(deleteBookMarkFromCell:) forControlEvents: UIControlEventTouchUpInside];
    [cell.content addTarget:self action:@selector(changeToPage:) forControlEvents: UIControlEventTouchUpInside];
    if(indexPath.row < [bookmarks count]){
        [cell setItemData:[bookmarks objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (IBAction) addBookMark:(id)sender
{
    [delegate addNewBookMark];
}

- (void) deleteBookMarkFromCell:(id)sender
{
    UIButton * btnSender = (UIButton *)sender;
    MRBookmarkCell * cell = (MRBookmarkCell *)btnSender.superview;
    [delegate deleteBoolMark:cell.bookMark.pid Page:cell.bookMark.pagenum];
}

- (void) changeToPage: (id)sender
{
    UIButton * btnSender = (UIButton *)sender;
    MRBookmarkCell * cell = (MRBookmarkCell *)btnSender.superview;
    NSIndexPath * indexPath = [bookMarkTable indexPathForCell:cell];
    MRBookMark * bookmark = [bookmarks objectAtIndex:indexPath.row];
    [delegate activateBookMark:bookmark.pid Page:bookmark.pagenum];
}

@end
