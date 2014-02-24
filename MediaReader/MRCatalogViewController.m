//
//  MRCatalogViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRCatalogViewController.h"
#import "JSONKit.h"
#import "MRCatalogItem.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "KSUtility.h"
#import "MRCatalogCell.h"
#import "MRAppUtil.h"
#import "KSTip.h"

@interface MRCatalogViewController ()
@property (retain, nonatomic) MPMoviePlayerViewController     * _player;
@end

@implementation MRCatalogViewController
@synthesize _player;
@synthesize delegate;
@synthesize _tableView;

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
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.allowsSelection = NO;
    [_tableView setBounces:NO];
//    _tableView.layer.borderWidth = 2.0f;
//    _tableView.layer.borderColor = [UIColor colorWithRed:0.776 green:0.776 blue:0.776 alpha:1.0].CGColor;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.776 alpha:1.0]];
    [_labelLine setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    [_labelCatalog setTextColor:[UIColor colorWithRed:0.4 green:0.2 blue:0.0 alpha:1.0]];
    [self addGesture];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.wantsFullScreenLayout = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) reloadData
{
    [_tableView reloadData];
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

- (void) startPlayVideo :(id)sender
{
    UIButton * button = (UIButton *)sender;
    MRCatalogCell * cell = (MRCatalogCell *)button.superview;
    [self playVideo:[cell.data pid]];
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

- (void) startUserNote :(id)sender
{
    UIButton * button = (UIButton *)sender;
    MRCatalogCell * cell = (MRCatalogCell *)button.superview;
    MRBookNoteViewController * bookNoteController = [[MRBookNoteViewController alloc] init];
    bookNoteController.pId = [cell data].pid;
    [self presentModalViewController:bookNoteController animated:YES];
    [bookNoteController release];
}

- (void) startReadContent :(id)sender
{
    UIButton * button = (UIButton *)sender;
    MRCatalogCell * cell = (MRCatalogCell *)button.superview;
    MRCatalogItem * data = cell.data;
    if(data != nil){
        [getAppDelegate().baseController loadContentView:data PageIndex:NO];
    }
}

- (void) instrImages :(id)sender
{
    UIButton * button = (UIButton *)sender;
    MRCatalogCell * cell = (MRCatalogCell *)button.superview;
    MRCatalogItem * data = cell.data;
    if(data != nil){
        [getAppDelegate().baseController loadContentView:data PageIndex:YES];
    }
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRCatalogCell * cell = nil;
    if(IS_IOS_5_0_OR_GRATER){
        UINib * nib = [UINib nibWithNibName:[MRCatalogCell nibName] bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:[MRCatalogCell cellIdentifier]];
        cell = (MRCatalogCell*)[tableView dequeueReusableCellWithIdentifier : [MRCatalogCell cellIdentifier]];
    }
    else{
        NSArray* arr = [[NSBundle mainBundle] loadNibNamed : [MRCatalogCell nibName] owner : tableView options : nil];
        cell = [arr objectAtIndex : 0];
    }
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [cell.btnvideo addTarget:self action:@selector(startPlayVideo:) forControlEvents: UIControlEventTouchUpInside];
    [cell.btnread addTarget:self action:@selector(startReadContent:) forControlEvents: UIControlEventTouchUpInside];
    [cell.btnshare addTarget:self action:@selector(startUserNote:) forControlEvents: UIControlEventTouchUpInside];
    [cell.btnimages addTarget:self action:@selector(instrImages:) forControlEvents: UIControlEventTouchUpInside];
    NSArray * catalogItems = getAppDelegate().baseController.catalogItems;
    if(indexPath.row < [catalogItems count]){
        [cell setItemData:[catalogItems objectAtIndex:indexPath.row]];
        if ([cell getItemPid:[catalogItems objectAtIndex:indexPath.row]]>20000)
        {
            [cell.btnimages setHidden:TRUE];
            [cell.btnshare setHidden:TRUE];
            [cell.btnvideo setHidden:TRUE];
            
//            [cell.division  setFrame:(CGRectMake)(cell.division.frame.origin.x,cell.division.frame.origin.y-60,cell.division.frame.size.width,cell.division.frame.size.height)];
            
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * catalogItems = getAppDelegate().baseController.catalogItems;
    return [catalogItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MRCatalogCell normalRowHeight];
}

@end
