//
//  MRCoverViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRCoverViewController.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"

@interface MRCoverViewController ()
@property (nonatomic, assign) UIImageView * _coverView;
@property (nonatomic, assign) UIButton    * _btnCatalog;
@end

@implementation MRCoverViewController

@synthesize _coverView;
@synthesize _btnCatalog;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(loadCatalog) withObject:nil afterDelay:4.0];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) loadCatalog
{
    [getAppDelegate().baseController loadCatalogView:YES];
}

- (IBAction) showCataLog:(id)sender
{
    [self loadCatalog];
}

@end
