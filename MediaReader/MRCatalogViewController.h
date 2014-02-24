//
//  MRCatalogViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MRBookNoteViewController.h"
#import "MRCopyRightViewController.h"

@protocol  MRCatalogViewControllerDelegate;

@interface MRCatalogViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
	id <MRCatalogViewControllerDelegate> delegate;
    IBOutlet    UITableView     * _tableView;
    IBOutlet    UIButton        * _btnCopyRight;
    IBOutlet    UILabel         * _labelLine;
    IBOutlet    UILabel         * _labelCatalog;
    MPMoviePlayerViewController     * _player;
}

@property (nonatomic, assign) id <MRCatalogViewControllerDelegate> delegate;
@property (nonatomic, assign) UITableView * _tableView;

- (void) startPlayVideo :(id)sender;

@end