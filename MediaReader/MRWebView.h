//
//  MRWebView.h
//  MediaReader
//
//  Created by jinbo he on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRWebScrollDelegate <NSObject>
- (void) moveVideoViewVirticallly:(CGFloat) distance;
@end

@interface MRWebView : UIWebView
{
    id<MRWebScrollDelegate> delegateMove;
}

@property (nonatomic, assign) id<MRWebScrollDelegate> delegateMove;

@end
