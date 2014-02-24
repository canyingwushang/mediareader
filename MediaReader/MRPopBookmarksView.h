//
//  MRPopBookmarksView.h
//  MediaReader
//
//  Created by jinbo he on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRPopBookmarksViewDelegate <NSObject>

- (void) addNewBookMark;
- (void) deleteBoolMark:(NSUInteger) pid Page:(NSUInteger) pagenum;
- (void) activateBookMark:(NSUInteger) pid Page:(NSUInteger) pagenum;

@end

@interface MRPopBookmarksView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray          * bookmarks;
    IBOutlet UITableView    * bookMarkTable;
    IBOutlet UIButton       * btnAdd;
    IBOutlet UILabel        * emptyTip;
    id<MRPopBookmarksViewDelegate> delegate;
}

@property (nonatomic, retain) NSMutableArray * bookmarks;

@property (assign, nonatomic) id<MRPopBookmarksViewDelegate> delegate;

- (void) setData : (NSMutableArray *) array;

@end
