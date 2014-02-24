//
//  MRContentViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRContentViewController.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "KSTip.h"
#import "MRBookMark.h"

#define TOOLBAR_ANIMATION_TIME 0.4

#define MOVIEBACK_PORT_X 39.0
#define MOVIEBACK_PORT_Y 101.0
#define MOVIEBACK_LAND_X 39.0
#define MOVIEBACK_LAND_Y 106.0

@interface  MRContentViewController()
{
    FlipTransition      * transition;
    MRWebView           * currentPageView;
}

@property (nonatomic, assign) MRWebView * webLeftView;
@property (nonatomic, assign) MRWebView * webRightView;
@property (nonatomic, assign) UIView    * toolBarView;
@property (nonatomic, retain) FlipTransition * transition;
@property (nonatomic, retain) MPMoviePlayerController * player;

@end

@implementation MRContentViewController

@synthesize webLeftView;
@synthesize webRightView;
@synthesize toolBarView;
@synthesize transition;
@synthesize player;
@synthesize catalogItem;
@synthesize loadImageIndex;
@synthesize bookmarkPage;
@synthesize pageSections;
@synthesize sectionId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        transition = [[FlipTransition alloc] init];
        transition.transitionType = FlipTransitionLeft;
        currentFontSize = 16;
        willBack = NO;
        loadImageIndex = NO;
        bookmarkPage = -1;
        bookMarkData = [[NSMutableArray alloc] init];
        currentNoteData = [[NSMutableString alloc] init];
        pageSections = [[NSMutableArray alloc] init];
        sectionId = [[NSString alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    KSRELEASE(transition);
    KSRELEASE(catalogItem);
    KSRELEASE(player);
    KSRELEASE(bookMarkData);
    KSRELEASE(popBookmark);
    //KSRELEASE(bookMarkView);
    KSRELEASE(currentNoteData);
    KSRELEASE(pageSections);
    KSRELEASE(sectionId);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:toolBarView];
    self.wantsFullScreenLayout = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [(UIScrollView *)[[webLeftView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[webRightView subviews] objectAtIndex:0] setBounces:NO];
    webRightView.delegate = self;
    webLeftView.delegate = self;
    webLeftView.delegateMove = self;
    webRightView.delegateMove = self;
    MRUFNotifyAddObserver(MRNotify_AppDidBackGround, @selector(saveCurrentReadState));
    MRUFNotifyAddObserver(MPMoviePlayerWillEnterFullscreenNotification, @selector(hideShowPlayer));
    MRUFNotifyAddObserver(MPMoviePlayerWillExitFullscreenNotification, @selector(hideShowPlayer));
    transitionCurlType = UIViewAnimationOptionTransitionCurlUp;
    
    [self addGesture];
    [self initPlayer];    
    [self initContent];
    [[KSTip shareTip]showInView:self.view withText:@"向右滑动翻页" imageName:nil];
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        movieBack.frame = CGRectMake(MOVIEBACK_LAND_X, MOVIEBACK_LAND_Y, movieBack.frame.size.width, movieBack.frame.size.height);
    }
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        movieBack.frame = CGRectMake(MOVIEBACK_PORT_X, MOVIEBACK_PORT_Y, movieBack.frame.size.width, movieBack.frame.size.height);
    }
    
    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"animation0.png"],
                                         [UIImage imageNamed:@"animation1.png"],
                                         [UIImage imageNamed:@"animation2.png"],
                                         [UIImage imageNamed:@"animation3.png"], nil];

    animatedImageView.animationDuration = 2.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView setFrame:CGRectMake(10,7,24,22)];
    [animatedImageView startAnimating];
    [btnNewMark addSubview:animatedImageView];
    [animatedImageView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [btnImages release];
    btnImages = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self hideToolBarDelay];
    
    [self performSelector:@selector(startVideoPlay) withObject:nil afterDelay:0.8];
}

- (void) addGesture
{
    UISwipeGestureRecognizer * rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] 
                                            initWithTarget:self action:@selector(swipeView:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [rightSwipeRecognizer release];
    
    UISwipeGestureRecognizer * leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] 
                                            initWithTarget:self action:@selector(swipeView:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [leftSwipeRecognizer release];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideToolBar:)];
    tapRecognizer.delegate = self;
    [webLeftView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    UITapGestureRecognizer * tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideToolBar:)];
    tapRecognizer1.delegate = self;
    [webRightView addGestureRecognizer:tapRecognizer1];
    [tapRecognizer1 release];
    
    UIPinchGestureRecognizer * pinchRecognizer = [[UIPinchGestureRecognizer alloc] 
                                                  initWithTarget:self action:@selector(pinchForFontSize:)];
    pinchRecognizer.delegate = self;
    [webLeftView addGestureRecognizer:pinchRecognizer];
    [pinchRecognizer release];
    
    UIPinchGestureRecognizer * pinchRecognizer1 = [[UIPinchGestureRecognizer alloc] 
                                                  initWithTarget:self action:@selector(pinchForFontSize:)];
    pinchRecognizer1.delegate = self;
    [webRightView addGestureRecognizer:pinchRecognizer1];
    [pinchRecognizer1 release];
    
//    UILongPressGestureRecognizer * longPressGestureRecognizer1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
//    longPressGestureRecognizer1.minimumPressDuration = 0.4f;
//    longPressGestureRecognizer1.delegate = self;
//    [webRightView addGestureRecognizer:longPressGestureRecognizer1];
//    [longPressGestureRecognizer1 release];
//    
//    UILongPressGestureRecognizer * longPressGestureRecognizer2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
//    longPressGestureRecognizer2.minimumPressDuration = 0.4f;
//    longPressGestureRecognizer2.delegate = self;
//    [webLeftView addGestureRecognizer:longPressGestureRecognizer2];
//    [longPressGestureRecognizer2 release];
}

- (void) initPlayer
{
    player = [[MPMoviePlayerController alloc] init];
    [player.view setFrame: movieBack.bounds];  // player's frame must match parent's
    [movieBack addSubview: player.view];
    
    orinigalVideoFrame = movieBack.frame;

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                            selector:@selector(movieStop:) 
                                                name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(durationAvailable:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:player];
}

- (void) movieStop: (NSNotification*)notification
{
    NSLog(@"%@", [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]);
    if(willBack == YES){
        [player pause];
        [player stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:player] ;
        [player release];
        player = nil;
    }
    else{
        [player prepareToPlay];
        [player play];
        [player pause];
    }
}

- (void) startVideoPlay
{
    NSString * videopath = [getAppDelegate().baseController videoPath:catalogItem.pid];
    if(videopath != nil && [[NSFileManager defaultManager] fileExistsAtPath:videopath]){
        if(player.playbackState == MPMoviePlaybackStateStopped){
            [player setContentURL:[NSURL fileURLWithPath:videopath]];
            [player prepareToPlay];
            [player play];
            if(loadImageIndex == YES)
            {
                [player pause];
            }
        }

    }
    else{
        if (catalogItem.pid<20000)//for other book's info which don't have video file.
        {
          [[KSTip shareTip]showInView:self.view withText:@"无法找到相关视频" imageName:nil];
          DSLog(@"videopath error");
        }
    }
}

- (void) loadBookmarks
{
    [bookMarkData removeAllObjects];
    NSArray * bookMarkDicts = [getAppDelegate().baseController.fileSystem queryBookmarkList];
    for (NSDictionary * dict in bookMarkDicts) {
        //if([[dict objectForKey:@"pid"] intValue] == catalogItem.pid){
        if(YES){
            MRBookMark * item = [[MRBookMark alloc] init];
            item.pid = [[dict objectForKey:@"pid"] intValue];
            item.pagenum = [[dict objectForKey:@"pagenum"] intValue];
            [bookMarkData addObject:item];      
            [item release];
        }
    }
}

- (void) initContent
{
    currentPageView = webLeftView;
    if(loadImageIndex)
    {
        currentPage = catalogItem.imageindex;
    }
    else{
        if (bookmarkPage > 0)
        {
            currentPage = bookmarkPage;
        }
        else
        {
            if(getAppDelegate().baseController.settings.lastPid == [catalogItem pid]){
                NSInteger lastPage = getAppDelegate().baseController.settings.lastPage;
                if(lastPage > 0 && lastPage <= catalogItem.pages){
                    currentPage = lastPage;
                }
                else{
                    currentPage = 1;
                }
            }
            else{
                currentPage = 1;
            }
        }
    }
    
    [self hideShowPlayer];
    
    NSString * htmlPath =[NSString stringWithFormat:@"%@%d.html", [MRAppUtil getHTMLPath:catalogItem.pid], currentPage];
    DSLog(@"%@", htmlPath);
    if(htmlPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:htmlPath]){
        [currentPageView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    }
    else{
        [currentPageView loadHTMLString:@"无法正常显示该页内容!!!" baseURL:nil];
        [[KSTip shareTip]showInView:self.view withText:@"该页内容丢失" imageName:nil];
    }
    [self prepareNextPageData:webRightView Page:currentPage+1];
    //[self updateBookMarkButton];
}

- (void) durationAvailable:(NSNotification *) notification
{
    if(getAppDelegate().baseController.settings.lastPid == self.catalogItem.pid){
        CGFloat playtime = getAppDelegate().baseController.settings.lastPlayBack;
        if(playtime > 0 && playtime < player.duration){
            player.currentPlaybackTime = playtime;
        }
    }
}

- (void) preparePageData 
{
    NSString * htmlPath =[NSString stringWithFormat:@"%@%d.html", [MRAppUtil getHTMLPath:catalogItem.pid], currentPage];
    DSLog(@"preparepageData:%@", htmlPath);
    if([[NSFileManager defaultManager] fileExistsAtPath:htmlPath]){
        
        //crash
        DSLog(@"Peter:%@", [NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]);
        [currentPageView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
        
    }
    else{
        [currentPageView loadHTMLString:@"无法正常显示该页内容!!!" baseURL:nil];
    }
}

- (void) prepareNextPageData:(UIWebView *) webView Page:(NSUInteger) pagesNum
{
    if(pagesNum > 0 && pagesNum < catalogItem.pages+1){
        NSString * htmlPath =[NSString stringWithFormat:@"%@%d.html", [MRAppUtil getHTMLPath:catalogItem.pid], pagesNum];
        DSLog(@"prepareNextPageData%@", htmlPath);
        if([[NSFileManager defaultManager] fileExistsAtPath:htmlPath]){
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
        }
        else{
            [webView loadHTMLString:@"无法正常显示该页内容!!!" baseURL:nil];
        }
    }
}

- (void) swipeView:(UISwipeGestureRecognizer *)recognizer 
{
    [self switchViews:recognizer];
    [self preparePageContent:recognizer];
}

- (void) preparePageContent:(UISwipeGestureRecognizer *)recognizer 
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        if(currentPageView == webLeftView){
            [self prepareNextPageData:webRightView Page:currentPage+1];
        }
        else if(currentPageView == webRightView){
            [self prepareNextPageData:webLeftView Page:currentPage+1];
        }
    }
    else{
        if(currentPageView == webLeftView){
            [self prepareNextPageData:webRightView Page:currentPage-1];
        }
        else if(currentPageView == webRightView){
            [self prepareNextPageData:webLeftView Page:currentPage-1];
        }
    }
}

- (void) switchViews:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        int nextPage = currentPage;
        if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
            if(currentPage + 1 > catalogItem.pages){
                [[KSTip shareTip]showInView:self.view withText:@"这是最后一页" imageName:nil];
                return;
            }
            else{
                nextPage ++;
            }
            transition.transitionType = FlipTransitionLeft;
            transitionCurlType = UIViewAnimationOptionTransitionCurlUp;
        }
        else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
            if(currentPage - 1 < 1){
                [[KSTip shareTip]showInView:self.view withText:@"这是第一页" imageName:nil];
                return;
            }
            else{
                nextPage --;
            }
            transition.transitionType = FlipTransitionRight;
            transitionCurlType = UIViewAnimationOptionTransitionCurlDown;
        }
        [self switchToPage:nextPage];
    }
}

- (void) switchToPage:(NSUInteger) page
{
    currentPage = page;
    if(currentPageView == webLeftView){
        currentPageView = webRightView;
        [self performSelectorInBackground:@selector(preparePageData) withObject: nil];
        [self switchToRight];
    }
    else if(currentPageView == webRightView){
        currentPageView = webLeftView;
        [self performSelectorInBackground:@selector(preparePageData) withObject: nil];
        [self switchToLeft];
    }
    [self hideToolBarAnimation];
    //[self updateBookMarkButton];
}

- (IBAction) switchToImageindex:(id)sender
{
    if(currentPage != catalogItem.imageindex)
    {
        [self switchToPage:catalogItem.imageindex];
    }
}

- (IBAction) backToCatalog:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    willBack = YES;
    [self saveCurrentReadState];
    [player stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) trunBookMarkPage
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    willBack = YES;
    [self saveCurrentReadState];
    [player stop];
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void) showHideToolBar:(UITapGestureRecognizer *)recognizer 
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarAnimation) object:nil];
    if(isPopBookMarkShowing == YES){
        [popBookmark dismissAnimated:YES];
        isPopBookMarkShowing = NO;
        return;
    }
    CGFloat alpha = toolBarView.alpha;
    if(alpha < 0.1){
        alpha = 1.0;
    }
    else{
        alpha = 0.0;
    }
    [UIView beginAnimations:@"toolBar" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:TOOLBAR_ANIMATION_TIME];
    if(alpha > 0.9){
        [UIView setAnimationDidStopSelector:@selector(hideToolBarDelay)];
    }
    toolBarView.alpha = alpha;
    [UIView commitAnimations];
}

- (void) hideToolBarDelay
{
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarAnimation) object:nil];
    [self performSelector:@selector(hideToolBarAnimation) withObject:nil afterDelay:6.0];
}

- (void) hideToolBarAnimation
{
    if(isPopBookMarkShowing == YES){
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:TOOLBAR_ANIMATION_TIME];
    toolBarView.alpha = 0.0;
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) hideShowPlayer
{
    
    if([catalogItem.imagesindex indexOfObject:[NSString stringWithFormat:@"%d", currentPage]] == NSNotFound)
    {
        movieBack.hidden = NO;
    }
    else{
        movieBack.hidden = YES;
    }
}

- (void) switchToLeft
{
    [self hideShowPlayer];
    [UIView transitionWithView:self.view
                      duration:1.0
                       options:transitionCurlType
                    animations:^{
                        webRightView.hidden = YES;
                        webLeftView.hidden = NO;
                    }
                    completion:^(BOOL finished){
                        if(finished)
                        {
                            [self hideShowPlayer];
                        }
                    }];
    
//	UIView *containerView = webRightView.superview;
//
//	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
//	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
//	
//	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
//	//[webRightView removeFromSuperview];
//	//[containerView addSubview:webLeftView];
//    webRightView.hidden = YES;
//    webLeftView.hidden = NO;
//	currentPageView = webLeftView;
//    
//	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void) switchToRight
{
    [self hideShowPlayer];
    [UIView transitionWithView:self.view
                      duration:1.0
                       options:transitionCurlType
                    animations:^{
                        webLeftView.hidden = YES;
                        webRightView.hidden = NO;
                    }
                    completion:^(BOOL finished){
                        if(finished)
                        {
                            [self hideShowPlayer];
                        }
                    }];
    
//	UIView *containerView = webLeftView.superview;
//        
//	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
//	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
//	
//	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
//	//[webLeftView removeFromSuperview];
//	//[containerView addSubview:webRightView];
//    webLeftView.hidden = YES;
//    webRightView.hidden = NO;
//    
//	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (IBAction) playFullScreen:(id)sender
{
    NSString * videopath = [getAppDelegate().baseController videoPath:catalogItem.pid];
    if(videopath != nil && [[NSFileManager defaultManager] fileExistsAtPath:videopath]){
        if(![player isFullscreen]){
//            player.view.transform = CGAffineTransformIdentity;
//            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//            CGAffineTransform transform = CGAffineTransformIdentity;
//            if (orientation == UIInterfaceOrientationLandscapeLeft) {
//                transform = CGAffineTransformMakeRotation(M_PI*1.5);
//            } else if (orientation == UIInterfaceOrientationLandscapeRight) {
//                transform = CGAffineTransformMakeRotation(M_PI/2);
//            } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
//                transform = CGAffineTransformMakeRotation(-M_PI);
//            } else {
//                transform = CGAffineTransformIdentity;
//            }
//            [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
//            CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:duration];
//            player.view.transform = transform;
//            [UIView commitAnimations];
            [player setFullscreen:YES animated:YES];
        }
    }
    else{
        [[KSTip shareTip]showInView:self.view withText:@"无法找到相关视频" imageName:nil];
    }
}

//MPMoviePlayerWillEnterFullscreenNotification
- (void) willEnterFullScreen:(NSNotification *)anotification
{
    ;
}

- (IBAction) showBookmarks:(id)sender
{
    if(isPopBookMarkShowing == NO){
        //MRCatalogItem * newitem = [[MRCatalogItem alloc] init];
        if(bookMarkView == nil ){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MRPopBookmarksView" owner:self options:nil];
            bookMarkView = [nib objectAtIndex:0];
            bookMarkView.delegate = self;
        }
        if(popBookmark == nil){
            popBookmark = [[CMPopTipView alloc] initWithCustomView:bookMarkView];
            popBookmark.delegate = self;
            popBookmark.animation = CMPopTipAnimationSlide;
        }
        [popBookmark presentPointingAtView:sender inView:self.view animated:YES];
        isPopBookMarkShowing = YES;
        [self loadBookmarks];
        [bookMarkView setData:bookMarkData];
    }
    else{
        [popBookmark dismissAnimated:YES];
        isPopBookMarkShowing = NO;
    }
}

- (void) updateBookMarkButton
{
    BOOL exist = [getAppDelegate().baseController.fileSystem checkBookmarkExist:catalogItem.pid Page:currentPage];
    if(exist){
        [btnBookMark setBackgroundColor:[UIColor redColor]];
    }
    else{
        [btnBookMark setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void) popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    ;//TODO
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *filePath = [NSString stringWithFormat:@"%@/common.js", [MRAppUtil getCommonPath]];  
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath
                                            encoding:NSUTF8StringEncoding error:nil]; 
    if(jsString != nil){
        [webView stringByEvaluatingJavaScriptFromString:jsString]; 
    }
    KSRELEASE(jsString);
    [self changeFontSize:webLeftView FontSize:currentFontSize];
    [self changeFontSize:webRightView FontSize:currentFontSize];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (isPopBookMarkShowing == YES)
    {
        [popBookmark dismissAnimated:YES];
        isPopBookMarkShowing = NO;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
        movieBack.frame = CGRectMake(MOVIEBACK_PORT_X, MOVIEBACK_PORT_Y, movieBack.frame.size.width, movieBack.frame.size.height);
    }
    else{
        movieBack.frame = CGRectMake(MOVIEBACK_LAND_X, MOVIEBACK_LAND_Y, movieBack.frame.size.width, movieBack.frame.size.height);
    }
}

- (IBAction) enlargeFontSize:(id)sender
{
    [self hideToolBarDelay];
    if(currentFontSize < 22){
        currentFontSize += 2;
    }
    [self changeFontSize:webLeftView FontSize:currentFontSize];
    [self changeFontSize:webRightView FontSize:currentFontSize];
}

- (IBAction) reduceFontSize:(id)sender
{
    [self hideToolBarDelay];
    if(currentFontSize > 14){
        currentFontSize -= 2;
    }
    [self changeFontSize:webLeftView FontSize:currentFontSize];
    [self changeFontSize:webRightView FontSize:currentFontSize];
}

- (void) pinchForFontSize:(UIPinchGestureRecognizer *) recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if(recognizer.scale < 0.7 ){
            if(currentFontSize > 14){
                currentFontSize -= 2;
            }
        }
        if(recognizer.scale > 1.3){
            if(currentFontSize < 22){
                currentFontSize += 2;
            }
        }
        [self changeFontSize:webLeftView FontSize:currentFontSize];
        [self changeFontSize:webRightView FontSize:currentFontSize];
    }
}

- (void) changeFontSize:(UIWebView *) webView FontSize:(NSUInteger) fontsize
{
    [webView stringByEvaluatingJavaScriptFromString:
                    [NSString stringWithFormat:@"changeFontSize(%d);", fontsize]];
}

- (void) moveVideoViewVirticallly:(CGFloat)distance
{
    NSLog(@"%f", distance);
    CGRect frame = orinigalVideoFrame;
    frame.origin.y = orinigalVideoFrame.origin.y - distance;
    movieBack.frame = frame;
    [self.view bringSubviewToFront:toolBarView];
}

- (void) saveCurrentReadState
{
    getAppDelegate().baseController.settings.lastPage = currentPage;
    getAppDelegate().baseController.settings.lastPid = catalogItem.pid;
    if(player.playbackState == MPMoviePlaybackStatePlaying){
        getAppDelegate().baseController.settings.lastPlayBack = player.currentPlaybackTime;
    }
}

- (void) addNewBookMark
{
    [getAppDelegate().baseController.fileSystem insertBackupRecord:catalogItem.pid Page:currentPage];
    [self loadBookmarks];
    [bookMarkView setData:bookMarkData];
    //[self updateBookMarkButton];
}

- (void)deleteBoolMark:(NSUInteger)pid Page:(NSUInteger)pagenum
{
    [getAppDelegate().baseController.fileSystem deleteBookMarkList:pid Page:pagenum];
    [self loadBookmarks];
    [bookMarkView setData:bookMarkData];
    //[self updateBookMarkButton];
}

- (void)activateBookMark:(NSUInteger)pid Page:(NSUInteger)pagenum
{
    if(pid == catalogItem.pid && pagenum == currentPage){
        return;
    }
    if (pid == catalogItem.pid)
    {
        currentPage = pagenum;
        if(currentPageView == webLeftView){
            currentPageView = webRightView;
            [self performSelectorInBackground:@selector(preparePageData) withObject: nil];
            [self switchToRight];
        }
        else if(currentPageView == webRightView){
            currentPageView = webLeftView;
            [self performSelectorInBackground:@selector(preparePageData) withObject: nil];
            [self switchToLeft];
        }
        [self hideToolBarAnimation];
        //[self updateBookMarkButton];
        [[KSTip shareTip]showInView:self.view withText:[NSString stringWithFormat:@"第%d页", pagenum] imageName:nil];
    }
    else
    {
        [self trunBookMarkPage];
        MRContentViewController * _contentViewController = [[MRContentViewController alloc]
                                                            initWithNibName:@"MRContentViewController" bundle:nil];
        _contentViewController.catalogItem = [getAppDelegate().baseController getCatalogItem:pid];
        _contentViewController.loadImageIndex = NO;
        _contentViewController.bookmarkPage = pagenum;
        [getAppDelegate().baseController.navigationController pushViewController:_contentViewController animated:YES];
        [_contentViewController release];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * str = [[request URL] absoluteString];
    NSArray * strs = [str componentsSeparatedByString:@"__"];
    if([strs count] == 3){
        NSString * noteData = [strs objectAtIndex:2];
        NSString * noteDataDecoding = [noteData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        noteDataDecoding = [noteDataDecoding stringByReplacingOccurrencesOfString:@"<dd>" withString:@""];
        noteDataDecoding = [noteDataDecoding stringByReplacingOccurrencesOfString:@"</dd>" withString:@""];
        noteDataDecoding = [noteDataDecoding stringByReplacingOccurrencesOfString:@"<dt>" withString:@""];
        noteDataDecoding = [noteDataDecoding stringByReplacingOccurrencesOfString:@"</dt>" withString:@""];
        [currentNoteData setString:noteDataDecoding];
        NSNumber * secctionNum = [strs objectAtIndex:1];
        self.sectionId = [NSString stringWithFormat:@"%d__%02d%02d", catalogItem.pid, currentPage, [secctionNum intValue]];
        DSLog(@"%@", sectionId);
        return NO;
    }
    return YES;
}

- (IBAction) startUserNote:(id)sender
{
    if([currentNoteData isEqualToString:@""]){
        [[KSTip shareTip]showInView:self.view withText:@"请先点击选中一段文字～" imageName:nil];
        return;
    }
    if(player.playbackState == MPMoviePlaybackStatePlaying)
    {
        [player pause];
    }
    MRBookNoteViewController * bookNoteController = [[MRBookNoteViewController alloc] init];
    bookNoteController.sectionId = sectionId;
    bookNoteController.pId = catalogItem.pid;
    bookNoteController.contentData = currentNoteData;
    bookNoteController.delegate = self;
    [self presentModalViewController:bookNoteController animated:YES];
    [bookNoteController release];
}

- (void) dismissBookNote
{
    if(player.playbackState == MPMoviePlaybackStatePaused)
    {
        [player play];
    }
}

- (NSString *)getSectionContent:(NSString *)sectionId
{
    return nil;
}

- (void)longPressHandle:(UILongPressGestureRecognizer *)recognizer
{
    ;
}

@end
