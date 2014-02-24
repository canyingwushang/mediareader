//
//  MRBookNoteViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRBookNoteViewControllerDelegate <NSObject>

- (void) dismissBookNote;

@end

@interface MRBookNoteViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextView * content;
    IBOutlet UITextView * note;
    IBOutlet UIButton   * btnOtherShare;
    IBOutlet UIButton   * btnShare;
    IBOutlet UIButton   * btnSave;
    
    NSUInteger            pId;
    NSString            * sectionId;
    NSString            * contentData;
    id<MRBookNoteViewControllerDelegate> delegate;
}

@property (assign, nonatomic) NSUInteger        pId;
@property (retain, nonatomic) NSString    * sectionId;
@property (retain, nonatomic) NSString    * contentData;
@property (assign, nonatomic) id<MRBookNoteViewControllerDelegate> delegate;

@end
