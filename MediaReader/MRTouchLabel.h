//
//  MRTouchLabel.h
//  MediaReader
//
//  Created by canyingwushang on 12-11-4.
//
//

#import <UIKit/UIKit.h>
#import "MRBookNote.h"

@protocol  MRTouchLabelDelegate<NSObject>

@required
- (void)touchUp:(id) sender;

@end

@interface MRTouchLabel : UILabel
{
    NSUInteger dataLines;
    BOOL needExpand;
    BOOL isExpanding;
    id<MRTouchLabelDelegate> delagate;
    MRBookNote *data;
    NSUInteger index;
}

@property (assign, nonatomic) NSUInteger dataLines;
@property (assign, nonatomic) BOOL needExpand;
@property (assign, nonatomic) BOOL isExpanding;
@property (assign, nonatomic) id<MRTouchLabelDelegate> delagate;
@property (retain, nonatomic) MRBookNote *data;
@property (assign, nonatomic) NSUInteger index;

@end
