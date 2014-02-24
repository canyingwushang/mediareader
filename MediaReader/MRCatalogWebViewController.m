//
//  MRCatalogWebViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRCatalogWebViewController.h"
#import "MRCatalogViewController.h"
#import "JSONKit.h"
#import "MRCatalogItem.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "KSUtility.h"
#import "MRCatalogCell.h"
#import "MRAppUtil.h"
#import "KSTip.h"

#define READ_CONTENT    @"read_at"
#define READ_INSTR      @"instr"
#define READ_NOTESHARE  @"noteshare"
#define READ_VIDEO      @"video_dr"
#define READ_COPYRIGHT  @"copyright"

@interface MRCatalogWebViewController ()
@property (retain, nonatomic) MPMoviePlayerViewController     * _player;
@end

@implementation MRCatalogWebViewController

@synthesize catalogWeb;
@synthesize _player;

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
    self._player = nil;
    self.catalogWeb = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    catalogWeb.delegate = self;
    
    NSString * htmlPath =[NSString stringWithFormat:@"%@/catalog.html", [MRAppUtil getCommonPath]];
    DSLog(@"%@", htmlPath);
    if(htmlPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:htmlPath]){
        [catalogWeb loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    }
    else{
        [catalogWeb loadHTMLString:@"无法正常显示该页内容!!!" baseURL:nil];
        [[KSTip shareTip]showInView:self.view withText:@"该页内容丢失" imageName:nil];
    }
    [self addGesture];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
        [catalogWeb setScalesPageToFit:NO];
        [catalogWeb reload];
    }
    else{
        [catalogWeb setScalesPageToFit:YES];
        [catalogWeb reload];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) addGesture
{
    UISwipeGestureRecognizer * rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(backCover:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [rightSwipeRecognizer release];
}

- (void) backCover: (UISwipeGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", [[request URL] absoluteString]);
    NSString * url = [[[request URL] absoluteString] lastPathComponent];
    NSArray * arrays = [url componentsSeparatedByString:@"#"];
    if([arrays count] == 2){
        NSString * type = [arrays objectAtIndex:0];
        if([type isEqualToString:READ_COPYRIGHT]){
            [self showCopyRight];
        }
        else{
            NSUInteger pid = [[arrays objectAtIndex:1] intValue];
            if(pid > 0 && type != nil){
                if([type isEqualToString:READ_INSTR]){
                    [[KSTip shareTip]showInView:self.view withText:@"样式同内容页" imageName:nil];
                }
                else if([type isEqualToString:READ_VIDEO]){
                    [self playVideo:pid];
                }
                else if([type isEqualToString:READ_CONTENT]){
                    [self startReadContent:pid];
                }
                else if([type isEqualToString:READ_NOTESHARE]){
                    [self startUserNote:pid];
                }
            }
        }
    }
    return YES;
}

- (void) showCopyRight
{
    MRCopyRightViewController * copyRightController = [[MRCopyRightViewController alloc] init];
    [self presentModalViewController:copyRightController animated:YES];
    [copyRightController release];
}

- (void) playVideo:(NSUInteger ) pid
{
    NSString * path = [getAppDelegate().baseController videoPath:pid];
    if(path == nil || ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[KSTip shareTip]showInView:self.view withText:@"无法找到相关视频" imageName:nil];
        return;
    }
    _player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [self presentModalViewController:_player animated:YES];
    [_player release];
}

- (void) startUserNote :(NSUInteger ) pid
{
    MRBookNoteViewController * bookNoteController = [[MRBookNoteViewController alloc] init];
    bookNoteController.pId = pid;
    [self presentModalViewController:bookNoteController animated:YES];
    [bookNoteController release];
}

- (void) startReadContent :(NSUInteger ) pid
{
    NSArray * catalogItems = [getAppDelegate().baseController catalogItems];
    MRCatalogItem * data = nil;
    for (MRCatalogItem * item in catalogItems) {
        if(item.pid == pid){
            data = item;
            break;
        }
    }
    if(data != nil){
        [getAppDelegate().baseController loadContentView:data PageIndex:NO];
    }
}

@end
