//
//  MRBookNoteOtherShareViewController.h
//  MediaReader
//
//  Created by canyingwushang on 12-9-22.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MRTouchLabel.h"

@interface MRBookNoteOtherShareViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, MRTouchLabelDelegate>
{
    IBOutlet UITextView * _textView;
    IBOutlet MRTouchLabel * noteA;
    IBOutlet MRTouchLabel * noteB;
    IBOutlet MRTouchLabel * noteC;
    IBOutlet MRTouchLabel * noteD;
    IBOutlet MRTouchLabel * noteE;
    IBOutlet UIButton * btnAdd;
    IBOutlet UIButton * btnShare;
    
    NSMutableArray * localNotes;
    NSArray * netNotes;
    NSMutableArray * labelNotes;
    NSInteger pid;
    NSMutableDictionary * contentDict;
    NSUInteger currentAIndex;
    MRBookNote *currentNote;
}

@property (nonatomic, retain) NSMutableArray * localNotes;
@property (nonatomic, retain) NSArray * netNotes;
@property (nonatomic, retain) NSMutableArray * labelNotes;
@property (nonatomic, assign) NSInteger pid;

@end
