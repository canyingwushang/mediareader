//
//  MRBookmarkCell.h
//  MediaReader
//
//  Created by jinbo he on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRBookMark.h"

@interface MRBookmarkCell : UITableViewCell
{
    IBOutlet UIButton * delmark;
    IBOutlet UILabel  * title;
    IBOutlet UIButton  * content;
    
    MRBookMark * bookMark;
}

@property (nonatomic, retain) MRBookMark * bookMark;
@property (nonatomic, assign) IBOutlet UIButton * delmark;
@property (nonatomic, assign) IBOutlet UIButton * content;

+ (NSString*) cellIdentifier;
+ (NSString*) nibName;
+ (NSInteger) normalRowHeight;

- (void) setItemData: (MRBookMark *) _bookmark;

@end
