//
//  MRContentViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FlipTransition.h"
#import "HMGLTransitionManager.h"
#import "CMPopTipView.h"
#import "MRWebView.h"
#import "MRPopBookmarksView.h"
#import "MRBookNoteViewController.h"

@class MRCatalogItem;
@class MRPopBookmarksView;

@interface MRContentViewController : UIViewController<UIGestureRecognizerDelegate, CMPopTipViewDelegate, UIWebViewDelegate, MRWebScrollDelegate, MRPopBookmarksViewDelegate, MRBookNoteViewControllerDelegate>
{
    IBOutlet MRWebView * webLeftView;
    IBOutlet MRWebView * webRightView;
    IBOutlet UIView    * toolBarView;
    IBOutlet UIButton  * btnBack;
    IBOutlet UIButton  * btnReduce;
    IBOutlet UIButton  * btnEnlarge;
    IBOutlet UIButton  * btnBookMark;
    IBOutlet UIButton  * btnNewMark;
    IBOutlet UIButton  * btnImages;
    IBOutlet UIView    * movieBack;
    UILabel            * labelPage;
    
    NSMutableArray     * bookMarkData;
    MRCatalogItem      * catalogItem;
    MPMoviePlayerController * player;
    MRPopBookmarksView * bookMarkView;
    CMPopTipView * popBookmark;
    
    NSUInteger currentPage;
    NSUInteger rightPrepare;
    NSUInteger leftPrepare;
    NSUInteger transitionCurlType;
    
    BOOL        isPopBookMarkShowing;
    BOOL        willBack;
    NSUInteger      currentFontSize;
    CGRect          orinigalVideoFrame;
    NSMutableString        * currentNoteData;
    BOOL                loadImageIndex;
    NSInteger           bookmarkPage;
    NSMutableArray * pageSections;
    NSString * sectionId;
}

@property (retain, nonatomic) MRCatalogItem  * catalogItem;
@property (nonatomic) BOOL                loadImageIndex;
@property (nonatomic) NSInteger           bookmarkPage;
@property (nonatomic, retain) NSMutableArray * pageSections;
@property (nonatomic, retain) NSString * sectionId;

@end
