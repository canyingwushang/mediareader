//
//  MRWebView.m
//  MediaReader
//
//  Created by jinbo he on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRWebView.h"

@implementation MRWebView

@synthesize delegateMove;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [delegateMove moveVideoViewVirticallly:scrollView.contentOffset.y];
}

@end
