//
//  MRBookNoteViewController.m
//  MediaReader
//
//  Created by jinbo he on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRBookNoteViewController.h"
#import "KSTip.h"
#import "MRViewController.h"
#import "MRAppDelegate.h"
#import "NetUtils.h"
#import "MRBookNoteOtherShareViewController.h"

@interface MRBookNoteViewController ()

@end

@implementation MRBookNoteViewController

@synthesize pId;
@synthesize sectionId;
@synthesize contentData;
@synthesize delegate;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.contentData = nil;
    [sectionId release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [content setEditable:NO];
    [content setText:contentData];
    // Do any additional setup after loading the view from its nib.
    
    [[btnOtherShare layer] setBorderWidth:1.0f];
    [[btnOtherShare layer] setCornerRadius:8.0f];
    [[btnOtherShare layer] setMasksToBounds:YES];
    [[btnOtherShare layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];

    [[content layer] setBorderWidth:1.0f];
    [[content layer] setCornerRadius:8.0f];
    [[content layer] setMasksToBounds:YES];
    [[content layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];

    [[note layer] setBorderWidth:1.0f];
    [[note layer] setCornerRadius:8.0f];
    [[note layer] setMasksToBounds:YES];
    [[note layer] setBorderColor:[[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:198.0/255.0 alpha:1] CGColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeFrameByOrientation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction) goback:(id)sender
{
    [delegate dismissBookNote];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) saveNote:(id)sender
{
    NSString * notestr = note.text;
    NSString * contentstr = content.text;
    if(notestr == nil || [notestr length] == 0 || [notestr isEqualToString:@"写点什么吧"]){
        [[KSTip shareTip]showInView:self.view withText:@"笔记不能为空哦" imageName:nil];
    }
    else{
        [getAppDelegate().baseController.fileSystem insertBookNote:pId Section:sectionId BookContent:contentstr Note:notestr];
        [[KSTip shareTip]showInView:self.view withText:@"保存成功" imageName:nil];
        [note setSelectedRange:NSMakeRange(note.text.length -1, 0)];
    }
}

- (IBAction) shareNote:(id)sender
{
    if([getAppDelegate() isNetworkAvailable] == YES)
    {
        NSString * notestr = note.text;
        if(notestr != nil && [notestr length] != 0 && ![notestr isEqualToString:@"写点什么吧"]){
            [btnShare setEnabled:NO];
            [[KSTip shareTip]showInView:self.view withText:@"正在分享笔记~"];
            [self performSelectorInBackground:@selector(commitNote) withObject:nil];
        }
        else{
            [[KSTip shareTip]showInView:self.view withText:@"笔记不能为空哦" imageName:nil];
        }
    }
    else
    {
        [[KSTip shareTip]showInView:self.view withText:@"网络连接失败，已将您的笔记保存在本地，可稍后分享。" imageName:nil];
    }
}

- (void) commitNote
{
    if(commitReview(sectionId, note.text))
    {
        [self performSelectorOnMainThread:@selector(shareSuccess) withObject:nil waitUntilDone:NO];
    }
    else{
        [self performSelectorOnMainThread:@selector(shareFail) withObject:nil waitUntilDone:NO];
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

- (IBAction) viewOtherShares:(id)sender
{
    if([getAppDelegate() isNetworkAvailable] == YES)
    {
        [[KSTip shareTip]showInView:self.view withText:@"正在获取读者分享"];
        [self performSelectorInBackground:@selector(getAllShares) withObject:nil];
    }
    else
    {
        [[KSTip shareTip]showInView:self.view withText:@"网络无法连通, 请检查!" imageName:nil];
    }
}

- (void) getAllShares
{
    NSArray * localArray = [self queryLocalNotes];
    NSArray * netArrays = [NSArray array];
    if ([localArray count] < 5)
    {
        netArrays = getReview ([NSString stringWithFormat:@"%d", pId], 1, 6);
    }
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:netArrays, @"netdata", localArray, @"localdata", nil];
    if([netArrays count] > 0 || [localArray count] > 0)
    {
        [self performSelectorOnMainThread:@selector(showOthersShare:) withObject:dict waitUntilDone:NO];
    }
    else{
        [self performSelectorOnMainThread:@selector(noShare) withObject:nil waitUntilDone:NO];
    }
}

- (void) noShare
{
    [[KSTip shareTip] showInView:self.view withText:@"暂时没有读者分享" imageName:nil];
}

- (void) showOthersShare:(id) obj
{
    [[KSTip shareTip]hide];
    NSDictionary * dict = obj;
    MRBookNoteOtherShareViewController * otherShareView = [[MRBookNoteOtherShareViewController alloc] init];
    otherShareView.netNotes = [dict objectForKey:@"netdata"];
    otherShareView.localNotes = [dict objectForKey:@"localdata"];
    otherShareView.pid = pId;
    [self presentModalViewController:otherShareView animated:YES];
    [otherShareView release];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"写点什么吧"]){
        textView.text = @"";
    }
    return YES;
}

- (NSMutableArray *)queryLocalNotes
{
    NSMutableArray * localNotes = [[NSMutableArray alloc] init];
    [localNotes addObjectsFromArray:[getAppDelegate().baseController.fileSystem queryBooknoteList:pId]];
    return [localNotes autorelease];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [note resignFirstResponder];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self changeFrameByOrientation:self.interfaceOrientation];
}

- (void)changeFrameByOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIDeviceOrientationIsPortrait(interfaceOrientation))
    {
        content.frame = CGRectMake(20.0f, 135.0f, 724.0f, 380.0f);
        btnOtherShare.frame = CGRectMake(20.0f, 560.0f, 723.0f, 40.0f);
        note.frame = CGRectMake(20.0f, 622.0f, 724.0f, 300.0f);
    }
    else
    {
        content.frame = CGRectMake(20.0f, 135.0f, 984.0f, 230.0f);
        btnOtherShare.frame = CGRectMake(20.0f, 390.0f, 984.0f, 40.0f);
        note.frame = CGRectMake(20.0f, 460.0f, 984.0f, 230.0f);
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (![note isFirstResponder])
    {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect newFrame = CGRectMake(note.frame.origin.x, note.frame.origin.y - keyboardRect.size.height, note.frame.size.width, note.frame.size.height);
    [self.view bringSubviewToFront:note];
    [UIView animateWithDuration:animationDuration animations:^{
        note.frame = newFrame;
    }];
}

- (void)keyboardWillhide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect newFrame = CGRectMake(note.frame.origin.x, note.frame.origin.y + keyboardRect.size.height, note.frame.size.width, note.frame.size.height);
    
    [UIView animateWithDuration:animationDuration animations:^{
        note.frame = newFrame;
    }];
}

@end
