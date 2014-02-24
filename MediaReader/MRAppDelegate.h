//
//  MRAppDelegate.h
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@class MRViewController;

@interface MRAppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability * hostReach;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MRViewController *baseController;

@property (nonatomic, retain) Reachability * hostReach;

- (BOOL) isNetworkAvailable;

@end
