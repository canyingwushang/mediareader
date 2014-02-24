//
//  MRViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSettings.h"
#import "MRCoverViewController.h"
#import "MRCatalogItem.h"
#import "MRFileSystem.h"

@class MRCatalogItem;

@interface MRViewController : UIViewController
{
    AppSettings * settings;
    NSMutableArray              * catalogItems;
    IBOutlet    UIImageView * coverimg;
    MRFileSystem * fileSystem;
}

@property (nonatomic, retain) AppSettings * settings;
@property (nonatomic, retain) UIImageView * coverimg;
@property (nonatomic, retain) NSMutableArray *    catalogItems;
@property (nonatomic, retain)  MRFileSystem * fileSystem;

- (void) persistLoad;

- (void) persistSave;

- (void) loadContentView:(MRCatalogItem *) data PageIndex:(BOOL) pageindex;
- (void) loadCoverView;
- (void) loadCatalogView:(BOOL) animation;
- (NSString*) videoPath:(NSUInteger ) pid;
- (NSString *) getIndexName:(NSUInteger) pid;
- (MRCatalogItem *) getCatalogItem:(NSUInteger) pid;
- (MRCatalogItem * ) checkOldReadState;

@end
