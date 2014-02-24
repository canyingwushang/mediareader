//
//  MRBookNoteOtherShareViewController.m
//  MediaReader
//
//  Created by canyingwushang on 12-9-22.
//
//

#import "MRBookNoteOtherShareViewController.h"
#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "MRFileSystem.h"
#import "MRBookNote.h"
#import "KSTip.h"
#import "NetUtils.h"

#define NOTE_LABEL_MARGIN_V 10.0f
#define NOTE_LABEL_MARGIN_LEFT_TOP 10.0f
#define NOTE_LABEL_BACK_VIEW_HEIGHT 70.0f
#define CHECK_STRING_VALID(str) (str != nil && [str length] > 0)

@implementation MRBookNoteOtherShareViewController

@synthesize localNotes;
@synthesize netNotes;
@synthesize labelNotes;
@synthesize pid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        contentDict = [[NSMutableDictionary alloc] init];
        labelNotes = [[NSMutableArray alloc] init];
        currentAIndex = 0;
    }
    return self;
}

- (void) dealloc
{
    [localNotes release];
    [netNotes release];
    [labelNotes release];
    [contentDict release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.776 alpha:1.0]];
    [[_textView layer] setBorderWidth:1.0f];
    [[_textView layer] setCornerRadius:8.0f];
    [[_textView layer] setMasksToBounds:YES];
    [[_textView layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    
    UIView *noteABack = [[UIView alloc] init];
    [[noteABack layer] setBorderWidth:1.0f];
    [[noteABack layer] setCornerRadius:8.0f];
    [[noteABack layer] setMasksToBounds:YES];
    [[noteABack layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    noteA.numberOfLines = 2;
    noteA.userInteractionEnabled = YES;
    [self.view addSubview:noteABack];
    [noteABack addSubview:noteA];
    noteABack.backgroundColor = noteA.backgroundColor;
    [noteABack release];
    
    UIView *noteBBack = [[UIView alloc] init];
    [[noteBBack layer] setBorderWidth:1.0f];
    [[noteBBack layer] setCornerRadius:8.0f];
    [[noteBBack layer] setMasksToBounds:YES];
    [[noteBBack layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    noteB.numberOfLines = 2;
    noteB.userInteractionEnabled = YES;
    [self.view addSubview:noteBBack];
    [noteBBack addSubview:noteB];
    noteBBack.backgroundColor = noteB.backgroundColor;
    [noteBBack release];
    
    UIView *noteCBack = [[UIView alloc] init];
    [[noteCBack layer] setBorderWidth:1.0f];
    [[noteCBack layer] setCornerRadius:8.0f];
    [[noteCBack layer] setMasksToBounds:YES];
    [[noteCBack layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    noteC.numberOfLines = 2;
    noteC.userInteractionEnabled = YES;
    [self.view addSubview:noteCBack];
    [noteCBack addSubview:noteC];
    noteCBack.backgroundColor = noteC.backgroundColor;
    [noteCBack release];
    
    UIView *noteDBack = [[UIView alloc] init];
    [[noteDBack layer] setBorderWidth:1.0f];
    [[noteDBack layer] setCornerRadius:8.0f];
    [[noteDBack layer] setMasksToBounds:YES];
    [[noteDBack layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    noteD.numberOfLines = 2;
    noteD.userInteractionEnabled = YES;
    [self.view addSubview:noteDBack];
    [noteDBack addSubview:noteD];
    noteDBack.backgroundColor = noteD.backgroundColor;
    [noteDBack release];
    
    UIView *noteEBack = [[UIView alloc] init];
    [[noteEBack layer] setBorderWidth:1.0f];
    [[noteEBack layer] setCornerRadius:8.0f];
    [[noteEBack layer] setMasksToBounds:YES];
    [[noteEBack layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    noteE.numberOfLines = 2;
    noteE.userInteractionEnabled = YES;
    [self.view addSubview:noteEBack];
    [noteEBack addSubview:noteE];
    noteEBack.backgroundColor = noteE.backgroundColor;
    [noteEBack release];
    
    noteA.delagate = self;
    noteB.delagate = self;
    noteC.delagate = self;
    noteD.delagate = self;
    noteE.delagate = self;
    
    noteA.index = 0;
    noteB.index = 1;
    noteC.index = 2;
    noteD.index = 3;
    noteE.index = 4;
    
    [self resumeLabelFrameByOrientation:self.interfaceOrientation];
    [self changeContentFrame:self.interfaceOrientation];
    
    // 本地数据在前,网络数据在后
    [labelNotes addObjectsFromArray:localNotes];
    [self transitNetNotes];
    [self loadLabelViewData];
}

- (void)resumeLabelFrameByOrientation:(UIInterfaceOrientation) interfaceOrientation
{
    CGFloat APPLICATION_SIZE_WIDTH = 768.0f;
    CGFloat NOTE_LABEL_BACK_VIEW_WIDTH = 680.0f;
    CGFloat NOTE_LABEL_A_ORIGIN_Y = 360.0f;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        APPLICATION_SIZE_WIDTH = 1024.0f;
        NOTE_LABEL_BACK_VIEW_WIDTH = 940.0f;
        NOTE_LABEL_A_ORIGIN_Y = 300.0f;
    }
    
    CGFloat x = (APPLICATION_SIZE_WIDTH - NOTE_LABEL_BACK_VIEW_WIDTH) / 2;
    
    CGRect noteABackRect = CGRectMake(x, NOTE_LABEL_A_ORIGIN_Y, NOTE_LABEL_BACK_VIEW_WIDTH, NOTE_LABEL_BACK_VIEW_HEIGHT);
    [noteA.superview setFrame:noteABackRect];
    CGRect noteARect = CGRectMake(NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_WIDTH - 2*NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_HEIGHT- 2*NOTE_LABEL_MARGIN_LEFT_TOP);
    [noteA setFrame:noteARect];
    noteA.superview.hidden = !CHECK_STRING_VALID(noteA.text);
    noteA.numberOfLines = 2;
    
    CGRect noteBBackRect = CGRectMake(x, noteABackRect.origin.y + noteABackRect.size.height + NOTE_LABEL_MARGIN_V, NOTE_LABEL_BACK_VIEW_WIDTH, NOTE_LABEL_BACK_VIEW_HEIGHT);
    [noteB.superview setFrame:noteBBackRect];
    CGRect noteBRect = CGRectMake(NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_WIDTH - 2*NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_HEIGHT- 2*NOTE_LABEL_MARGIN_LEFT_TOP);
    [noteB setFrame:noteBRect];
    noteB.superview.hidden = !CHECK_STRING_VALID(noteB.text);
    
    CGRect noteCBackRect = CGRectMake(x, noteBBackRect.origin.y + noteBBackRect.size.height + NOTE_LABEL_MARGIN_V, NOTE_LABEL_BACK_VIEW_WIDTH, NOTE_LABEL_BACK_VIEW_HEIGHT);
    [noteC.superview setFrame:noteCBackRect];
    CGRect noteCRect = CGRectMake(NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_WIDTH - 2*NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_HEIGHT- 2*NOTE_LABEL_MARGIN_LEFT_TOP);
    [noteC setFrame:noteCRect];
    noteC.superview.hidden = !CHECK_STRING_VALID(noteC.text);
    
    CGRect noteDBackRect = CGRectMake(x, noteCBackRect.origin.y + noteCBackRect.size.height + NOTE_LABEL_MARGIN_V, NOTE_LABEL_BACK_VIEW_WIDTH, NOTE_LABEL_BACK_VIEW_HEIGHT);
    [noteD.superview setFrame:noteDBackRect];
    CGRect noteDRect = CGRectMake(NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_WIDTH - 2*NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_HEIGHT- 2*NOTE_LABEL_MARGIN_LEFT_TOP);
    [noteD setFrame:noteDRect];
    noteD.superview.hidden = !CHECK_STRING_VALID(noteD.text);
    
    CGRect noteEBackRect = CGRectMake(x, noteDBackRect.origin.y + noteDBackRect.size.height + NOTE_LABEL_MARGIN_V, NOTE_LABEL_BACK_VIEW_WIDTH, NOTE_LABEL_BACK_VIEW_HEIGHT);
    [noteE.superview setFrame:noteEBackRect];
    
    CGRect noteERect = CGRectMake(NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_WIDTH - 2*NOTE_LABEL_MARGIN_LEFT_TOP, NOTE_LABEL_BACK_VIEW_HEIGHT- 2*NOTE_LABEL_MARGIN_LEFT_TOP);
    [noteE setFrame:noteERect];
    noteE.superview.hidden = !CHECK_STRING_VALID(noteE.text);
}

- (void)changeContentFrame:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, 196.0f);
    }
    else
    {
        _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, 150.0f);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
    {
        [self changeContentFrame:UIInterfaceOrientationPortrait];
    }
    else
    {
        [self changeContentFrame:UIDeviceOrientationLandscapeLeft];
    }
    [self resumeLabelFrameByOrientation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)transitNetNotes
{
    NSMutableArray * tmpNetNotes = [[NSMutableArray alloc] init];
    if (netNotes != nil && [netNotes count] != 0)
    {
        for (NSDictionary *dict in netNotes)
        {
            NSArray * keys = [dict allKeys];
            NSString * key = [keys objectAtIndex:0];
            if (key != nil && [key length] != 0)
            {
                if ([key rangeOfString:@"__"].length > 0)
                {
                    MRBookNote * tmpNote = [[MRBookNote alloc] init];
                    tmpNote.pid = pid;
                    tmpNote.sectionId = [key substringFromIndex:([key rangeOfString:@"__"].location + 2)];
                    NSString * netnote = [dict objectForKey:key];
                    tmpNote.note = [netnote stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    if ([contentDict objectForKey:key] != nil)
                    {
                        tmpNote.content = [contentDict objectForKey:key];
                    }
                    else
                    {
                        tmpNote.content = [self getPageString:tmpNote.sectionId];
                    }
                    [tmpNetNotes addObject:tmpNote];
                    [tmpNote release];
                }
            }
        }
    }
    [labelNotes addObjectsFromArray:tmpNetNotes];
    [tmpNetNotes release];
}


- (NSString *)getPageString:(NSString *)sectionId
{
    if ([sectionId length] != 4)
    {
        return nil;
    }
    NSMutableString * res = [[[NSMutableString alloc] init] autorelease];
    NSString * pageStr = [sectionId substringToIndex:2];
    NSString * sectionStr = [sectionId substringFromIndex:2];
    NSInteger sectionIndex = [sectionStr intValue] - 1;
    NSString * htmlPath =[NSString stringWithFormat:@"%@%d.html", [MRAppUtil getHTMLPath:pid], [pageStr intValue]];
    DSLog(@"%@", htmlPath);
    NSError * error = nil;
    if(htmlPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:htmlPath]){
        NSString * pageContent = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
        NSError *error = NULL;
        NSRegularExpression *regexa = [NSRegularExpression regularExpressionWithPattern:@"<a"
                                                                                options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matchessa = [regexa matchesInString:pageContent options:0 range:NSMakeRange(0, [pageContent length])];
        NSRegularExpression *regexenda = [NSRegularExpression regularExpressionWithPattern:@"a>"
                                                                                   options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matchesenda = [regexenda matchesInString:pageContent options:0 range:NSMakeRange(0, [pageContent length])];
        if ([matchessa count] == [matchesenda count])
        {
            NSTextCheckingResult * startRes = [matchessa objectAtIndex:sectionIndex];
            NSTextCheckingResult * endRes = [matchesenda objectAtIndex:sectionIndex];
            NSRange startRange =  startRes.range;
            NSRange endRange = endRes.range;
            NSString *contentTmp = [pageContent substringWithRange:NSMakeRange(startRange.location+38, (endRange.location - startRange.location + 2))];
            if (contentTmp != nil)
            {
                [contentDict setObject:contentTmp forKey:sectionId];
            }
            [res appendString:contentTmp];
        }
        else
        {
            DSLog(@"%@", @"当前页面格式有误");
        }
    }
    [res replaceOccurrencesOfString:@"<dd>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@"</dd>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@"<dt>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@"</dt>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@"</a>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    [res replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [res length])];
    return res;
}

- (void)chechNewNetData
{
    NSUInteger dataAIndex = currentAIndex;
    if (dataAIndex + 4 > [labelNotes count] - 1)
    {
        NSUInteger newNetDataCount = dataAIndex + 4 - [labelNotes count]; // 需要拉取两条数据
        NSUInteger startNetNum = [labelNotes count] - [localNotes count] + 1;
        NSUInteger endNetNum = startNetNum + newNetDataCount;
        if([getAppDelegate() isNetworkAvailable] == YES)
        {
            [[KSTip shareTip]showInView:self.view withText:@"正在获取读者分享"];
            NSDictionary * netNum = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:startNetNum], @"startNetNum", [NSNumber numberWithInt:endNetNum] ,@"endNetNum", nil];
            [self performSelectorInBackground:@selector(getNewNetData:) withObject:netNum];
        }
        else
        {
            [[KSTip shareTip]showInView:self.view withText:@"网络无法连通, 请检查!" imageName:nil];
        }
    }
    else
    {
        [self loadLabelViewData];
    }
}

- (void)getNewNetData:(NSDictionary *)dict
{
    NSNumber *startNetNum = [dict objectForKey:@"startNetNum"];
    NSNumber *endNetNum = [dict objectForKey:@"endNetNum"];
    self.netNotes = getReview ([NSString stringWithFormat:@"%d", pid], [startNetNum intValue], [endNetNum intValue]);
    [self transitNetNotes];
    [self performSelectorOnMainThread:@selector(loadLabelViewData) withObject:nil waitUntilDone:NO];
}

- (void)loadLabelViewData
{
    [[KSTip shareTip] hide];
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    [labelArray addObject:noteA];
    [labelArray addObject:noteB];
    [labelArray addObject:noteC];
    [labelArray addObject:noteD];
    [labelArray addObject:noteE];
    int index = currentAIndex;
    for (MRTouchLabel *label in labelArray) {
        if (([labelNotes count] - 1) >= index)
        {
            MRBookNote *data = [labelNotes objectAtIndex:index];
            if (data != nil)
            {
                label.data = data;
                if (label.data.isLocal == YES)
                {
                    [label setText:[NSString stringWithFormat:@"自己心得: %@", data.note]];
                }
                else
                {
                    [label setText:data.note];
                }
                label.hidden = NO;
                label.superview.hidden = NO;
            }
            else
            {
                label.data = nil;
                [label setText:@""];
                label.hidden = YES;
                label.superview.hidden = YES;
            }
        }
        else
        {
            label.data = nil;
            [label setText:@""];
            label.hidden = YES;
            label.superview.hidden = YES;
        }
        index ++;
    }
    [labelArray release];
}

- (IBAction) back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)touchUp:(id)sender
{
    MRTouchLabel *label = (MRTouchLabel*)sender;
    currentNote = label.data;
    if (label.data.isLocal)
    {
        btnShare.enabled = YES;
    }
    else
    {
        btnShare.enabled = NO;
    }
    if (label == noteA)
    {
        if (noteA.isExpanding == NO)
        {
            _textView.text = noteA.data.content;
            noteA.isExpanding = YES;
            // 展开
            if (noteA.dataLines > 2)
            {
                [self expandLabelAFrame];
            }
        }
        else
        {
            //_textView.text = @""; 
            noteA.isExpanding = NO;
            //下移
            [UIView animateWithDuration:0.8 animations:^{
                [self resumeLabelFrameByOrientation:self.interfaceOrientation];
            } completion:^(BOOL finished) {
                if (finished)
                {
                    if (currentAIndex <= 4)
                    {
                        currentAIndex = 0;
                        [self chechNewNetData];
                    }
                    else
                    {
                        currentAIndex = currentAIndex - 4;
                        [self chechNewNetData];
                        
                    }
                }
            }];
        }
    }
    else
    {
        currentAIndex = currentAIndex + label.index;
        [self chechNewNetData];
        noteA.isExpanding = YES;
        MRBookNote *noteAWill = [labelNotes objectAtIndex:currentAIndex];
        if (noteAWill.isLocal == YES)
        {
            [noteA setText:[NSString stringWithFormat:@"自己心得: %@", noteAWill.note]];
        }
        else
        {
            [noteA setText:noteAWill.note];
        }
        _textView.text = noteAWill.content;
        if (noteA.dataLines > 2)
        {
            [self expandLabelAFrame];
        }
        else
        {
            [UIView animateWithDuration:0.8 animations:^{
                [self resumeLabelFrameByOrientation:self.interfaceOrientation];
            } completion:^(BOOL finished) {
                if (finished)
                {
                    ;
                }
            }];
        }
    }
}

- (void) expandLabelAFrame
{
    UIView *labelABackView = noteA.superview;
    CGRect newABackFrame = CGRectMake(labelABackView.frame.origin.x, labelABackView.frame.origin.y, labelABackView.frame.size.width, NOTE_LABEL_BACK_VIEW_HEIGHT *3 + NOTE_LABEL_MARGIN_V * 2);
    CGSize noteATextSize = [noteA.text sizeWithFont:noteA.font];
    CGFloat labelAHeight = noteATextSize.height * (noteA.dataLines + 1);
    CGRect noteARect = CGRectMake(noteA.frame.origin.x, noteA.frame.origin.y, noteA.frame.size.width, labelAHeight);
    noteA.numberOfLines = noteA.dataLines + 1;
    [UIView animateWithDuration:0.8 animations:^{
        [labelABackView setFrame:newABackFrame];
        [noteA setFrame:noteARect];
        noteD.superview.hidden = YES;
        noteE.superview.hidden = YES;
        noteB.superview.frame = noteD.superview.frame;
        noteB.frame = noteD.frame;
        noteC.superview.frame = noteE.superview.frame;
        noteC.frame = noteE.frame;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (BOOL) commitNote:(NSString *)sectionId Note:(NSString *)note
{
    if(commitReview(sectionId, note))
    {
        [self performSelectorOnMainThread:@selector(shareSuccess) withObject:nil waitUntilDone:NO];
        return YES;
    }
    else{
        [self performSelectorOnMainThread:@selector(shareFail) withObject:nil waitUntilDone:NO];
        return NO;
    }
}

- (IBAction) shareNetNote:(id)sender
{
    if ([self commitNote:currentNote.sectionId Note:currentNote.note])
    {
        [getAppDelegate().baseController.fileSystem deleteBookNote:currentNote.sectionId Note:currentNote.note];
        currentNote.isLocal = NO;
        [labelNotes removeObject:currentNote];
        [localNotes removeObject:currentNote];
        [labelNotes insertObject:currentNote atIndex:[localNotes count]];
        [self loadLabelViewData];
    }
}

- (void) shareFail
{
    [[KSTip shareTip]showInView:self.view withText:@"分享失败" imageName:nil];
    [btnShare setEnabled:YES];
}

- (void) shareSuccess
{
    [[KSTip shareTip]showInView:self.view withText:@"分享成功" imageName:nil];
    [btnShare setEnabled:YES];
}

@end