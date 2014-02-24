//
//  MRCatalogCell.h
//  MediaReader
//
//  Created by jinbo he on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRCatalogItem.h"

@interface MRCatalogCell : UITableViewCell
{
    IBOutlet UIImageView * icon;
    IBOutlet UILabel     * title;
    IBOutlet UILabel     * subtitle;
    IBOutlet UIButton    * btnread;
    IBOutlet UIButton    * btnimages;
    IBOutlet UIButton    * btnshare;
    IBOutlet UIButton    * btnvideo;
    IBOutlet UIImageView * division;
    MRCatalogItem        * data;
}

@property (nonatomic, assign) UIImageView   * icon;
@property (nonatomic, assign) UILabel       * title;
@property (nonatomic, assign) UILabel       * subtitle;
@property (nonatomic, assign) UIButton      * btnread;
@property (nonatomic, assign) UIButton      * btnimages;
@property (nonatomic, assign) UIButton      * btnshare;
@property (nonatomic, assign) UIButton      * btnvideo;
@property (nonatomic, assign) UIImageView   * division;
@property (nonatomic, retain) MRCatalogItem * data;

+ (NSString*) cellIdentifier;
+ (NSString*) nibName;
+ (NSInteger) normalRowHeight;

- (void) setItemData:(MRCatalogItem *)adata;
- (NSInteger) getItemPid:(MRCatalogItem *)adata;

@end
