//
//  MRCatalogWebViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MRCatalogWebViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet    UIWebView * catalogWeb;
    MPMoviePlayerViewController     * _player;
}

@property (nonatomic, retain) IBOutlet    UIWebView * catalogWeb;

@end
