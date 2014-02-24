//
//  MRAppDelegate.m
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRAppDelegate.h"
//#import "FxNetworkCheck.h"
#import "MRViewController.h"

@implementation MRAppDelegate
@synthesize hostReach;
@synthesize window = _window;
@synthesize baseController = _baseController;

- (void)dealloc
{
    [_window release];
    [_baseController release];
    [hostReach release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.baseController = [[[MRViewController alloc] initWithNibName:@"MRViewController" bundle:nil] autorelease];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.baseController];
    [navigationController setNavigationBarHidden:YES];
    self.window.rootViewController = navigationController;
    [navigationController release];
    [self.window makeKeyAndVisible];
    hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[hostReach startNotifier];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //MRUFNotifyPostWithNil(MRNotify_AppDidBackGround);
    [[NSNotificationCenter defaultCenter] postNotificationName:MRNotify_AppDidBackGround object:nil];
    [_baseController persistSave];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_baseController persistLoad];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [_baseController persistSave];
}


- (BOOL)isNetworkAvailable
{
    return [hostReach currentReachabilityStatus] != NotReachable;
}

@end
