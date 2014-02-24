//
//  KSTip.m
//  LiveSpace
//
//  Created by lidong wang on 12-6-7.
//  Copyright (c) 2012年 kingsoft. All rights reserved.
//

#import "KSTip.h"

@implementation KSTip

-(void)hide:(BOOL)animated
{
    if(_tipView!=nil)
    {
        [_tipView hide:animated];
        KSRELEASE(_tipView);
    }

}

-(void)hide
{
    [self hide:YES];
}

- (void)showInView:(UIView*)view withText:(NSString*)text
{
    [self hide];
    
    _tipView = [[KSProgress alloc] initWithView:view];
    _tipView.frame = view.bounds;

    [view addSubview:_tipView];
    
    _tipView.labelText = text;
    
    [_tipView show:YES];
}

- (void)showInView:(UIView*)view withText:(NSString*)text imageName:(NSString *)name
{
    if (_tipView != nil) {
        [self hide];
    }
    
    _tipView = [[KSProgress alloc] initWithView:view];
	[view addSubview:_tipView];
    CGRect rect = view.bounds;
    rect.origin.x = 0;
    rect.origin.y =0;
    _tipView.frame = rect;
    _tipView.frame = rect;
    
    UIImageView* imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    _tipView.customView = imageview;
    [imageview release];
	
    // Set custom view mode
    _tipView.mode = KSProgressModeCustomView;
    _tipView.labelText = text;
	
    [_tipView show:YES];
	[_tipView hide:YES afterDelay:2.5];
}

#pragma mark - single instance
static KSTip* ktip = nil;

+(KSTip *) shareTip{
    @synchronized(self){
        if (ktip == nil) {
            [[self alloc] init];
        }
    }
    return ktip;
}

+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (ktip == nil) {
            ktip = [super allocWithZone:zone];
            return ktip;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

//据说不会被调用
-(void)dealloc
{
    KSRELEASE(_tipView);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
    }
    return self;
}


@end
