//
//  MRViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRViewController.h"
#import "MRAppUtil.h"
#import "MRContentViewController.h"
#import "MRCatalogViewController.h"
#import "MRCatalogWebViewController.h"
#import "JSONKit.h"

@interface MRViewController ()
{
    NSMutableDictionary     *		_dictAllPersistLoadedData;
    
    MRCoverViewController   *       _coverViewController;
}

@property (retain, nonatomic) NSMutableDictionary       *		_dictAllPersistLoadedData;
@property (retain, nonatomic) MRCoverViewController     *       _coverViewController;

@end

@implementation MRViewController

@synthesize coverimg;
@synthesize settings;
@synthesize _dictAllPersistLoadedData;
@synthesize _coverViewController;
@synthesize catalogItems;
@synthesize fileSystem;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self != nil){
        [self initialize];
    }
    return self;
}

- (void) dealloc
{
    self._dictAllPersistLoadedData = nil;
    self._coverViewController = nil;
    self.catalogItems = nil;
    self.fileSystem = nil;
    [super dealloc];
}

- (void) initialize
{
    //应用程序设置初始化
    [self loadCatalogData];
    fileSystem = [[MRFileSystem alloc] init];
    [fileSystem initFileSystem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addGestureRecognizer];
    //[self addScheduleLoad];
    if(YES){
    }
    else{
        //[self loadContentView];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) addGestureRecognizer
{
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
                                        initWithTarget:self action:@selector(loadCatalogOrContent)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (void) addScheduleLoad
{
    [self performSelector:@selector(loadCatalogOrContent) withObject:nil afterDelay:2.5];
}

- (void) cancelScheduleLoads
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadCatalogOrContent) object:nil];
}

- (MRCatalogItem * ) checkOldReadState
{
    MRCatalogItem * olditem = nil;
    if(settings.lastPid > 0)
    {
        for (MRCatalogItem * item in catalogItems) {
            if(item.pid == settings.lastPid){
                if(settings.lastPage > 0){
                    olditem = item;
                    break;
                }
            }
        }
    }
    return olditem;
}

- (void) loadCatalogOrContent
{
    [self cancelScheduleLoads];
    [self persistLoad];
    MRCatalogItem * olditem = [self checkOldReadState];
    if(olditem != nil){
        [self loadCatalogView:NO];
        [self loadContentView:olditem PageIndex:NO];
    }
    else{
        [self loadCatalogView:YES];
    }
}

- (void) loadCoverView
{
    if(_coverViewController == nil){
        _coverViewController = [[MRCoverViewController alloc] 
                                initWithNibName:@"MRCoverViewController" bundle:nil];
        _coverViewController.view.frame = self.view.bounds;
        [self.view addSubview:_coverViewController.view];
    }
    _coverViewController.view.hidden = NO;
}

- (void) loadContentView:(MRCatalogItem *) data PageIndex:(BOOL) pageindex
{
    MRContentViewController * _contentViewController = [[MRContentViewController alloc]
                                                        initWithNibName:@"MRContentViewController" bundle:nil];
    _contentViewController.catalogItem = data;
    _contentViewController.loadImageIndex = pageindex;
    [self.navigationController pushViewController:_contentViewController animated:YES];
    [_contentViewController release];
}

- (void) loadCatalogView:(BOOL) animation
{
    
    MRCatalogViewController * catalogViewController = [[MRCatalogViewController alloc] 
                                 initWithNibName:@"MRCatalogViewController" bundle:nil];
    [self.navigationController pushViewController:catalogViewController animated:animation];
    [catalogViewController release];
    /*
    MRCatalogWebViewController * catalogViewController = [[MRCatalogWebViewController alloc] 
                                initWithNibName:@"MRCatalogWebViewController" bundle:nil];
    [self.navigationController pushViewController:catalogViewController animated:animation];
    [catalogViewController release]; 
    */

}

- (void) persistLoad
{
    if(self.settings == nil){
        AppSettings * asettings = [[AppSettings alloc] init];
        [asettings initialize];
        self.settings = asettings;
        [asettings release];
    }
    
    NSString* plistPath = [MRAppUtil getPersistFilePath];
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithContentsOfFile : plistPath];
        self._dictAllPersistLoadedData = dict;
        [dict release];
    }
    [self.settings persistLoad:_dictAllPersistLoadedData];
    
    DSLog(@"settings.lastPid  %d", settings.lastPid);
    DSLog(@"settings.lastPage  %d", settings.lastPage);
    DSLog(@"settings.lastPlayBack  %d", settings.lastPlayBack);
}

- (void) persistSave
{
    if(self.settings == nil){
        AppSettings * asettings = [[AppSettings alloc] init];
        [asettings initialize];
        self.settings = asettings;
        [asettings release];
    }
    NSMutableDictionary * dictAllSections = [[NSMutableDictionary alloc] init];
    [self.settings persistSave:dictAllSections];
	NSString* plistPath = [MRAppUtil getPersistFilePath];
	[dictAllSections writeToFile : plistPath atomically : YES];
	[dictAllSections release];
}

- (void) loadCatalogData
{
    catalogItems = [[NSMutableArray alloc] init];
    [catalogItems removeAllObjects];
    NSString * cataLogJsonPath = [MRAppUtil getCatalogInDocs];
    if([[NSFileManager defaultManager] fileExistsAtPath:cataLogJsonPath]){
        NSData * jsonData = [NSData dataWithContentsOfFile:cataLogJsonPath];
        NSDictionary * jsonDict = [jsonData objectFromJSONData];
        NSArray * items = [jsonDict objectForKey:CATALOGITEMS];
        for (NSDictionary * item in items) {
            MRCatalogItem * catalogItem = [[MRCatalogItem alloc] init];
            catalogItem.pid = [[item objectForKey:CATALOGITEM_ID] integerValue];
            catalogItem.name = [item objectForKey:CATALOGITEM_NAME];
            catalogItem.indexname = [item objectForKey:CATALOGITEM_INDEXNAME];
            catalogItem.docpath = [item objectForKey:CATALOGITEM_DOC];
            catalogItem.videopath = [item objectForKey:CATALOGITEM_VIDEO];
            catalogItem.pages = [[item objectForKey:CATALOGITEM_PAGES] intValue];
            catalogItem.imageindex = [[item objectForKey:CATALOGITEM_IMAGEINDEX] intValue];
            catalogItem.imagesindex = [item objectForKey:CATALOGITEM_IMAGESINDEX];
            [catalogItems addObject:catalogItem];
            [catalogItem release];
        }
    }
    else{
        DSLog(@"loadCatalogData Error: Cannot Find JSON cataLogJsonPath is NULL");
    }
}

- (NSString*) videoPath:(NSUInteger ) pid
{
    NSString * videoName = nil;
    for (MRCatalogItem * item in catalogItems) {
        if(item.pid == pid){
            videoName = item.videopath;
            break;
        }
    }
    if(videoName == nil){
        return nil;
    }
    NSString * videoPath = [NSString stringWithFormat:@"%@%@", [MRAppUtil getVideoPath:pid], videoName];
    DSLog(@"%@", videoPath);
    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){
        return videoPath;
    }
    else{
        return nil;
    }
}

- (NSString *) getIndexName:(NSUInteger) pid
{
    NSMutableString * indexname = [[NSMutableString alloc] init];
    for (MRCatalogItem * item in catalogItems) {
        if(item.pid == pid){
            [indexname appendString:item.indexname];
            break;
        }
    }
    return [indexname autorelease];
}

- (MRCatalogItem *) getCatalogItem:(NSUInteger) pid
{
    MRCatalogItem * aitem = nil;
    for (MRCatalogItem * item in catalogItems) {
        if(item.pid == pid){
            aitem = item;
            break;
        }
    }
    return aitem;
}

@end
