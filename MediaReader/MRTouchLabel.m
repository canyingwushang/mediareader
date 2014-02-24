//
//  MRTouchLabel.m
//  MediaReader
//
//  Created by canyingwushang on 12-11-4.
//
//

#import "MRTouchLabel.h"
#import "math.h"

@implementation MRTouchLabel

@synthesize dataLines;
@synthesize needExpand;
@synthesize isExpanding;
@synthesize delagate;
@synthesize data;
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        needExpand = NO;
        isExpanding = NO;
        dataLines = 0;
        index = 0;
    }
    return self;
}

- (void)dealloc
{
    delagate = nil;
    KSRELEASE(data);
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delagate touchUp:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)setText:(NSString *)text
{
    CGSize textSize = [text sizeWithFont:self.font];
    dataLines = ceil(textSize.width/self.frame.size.width);
    if (dataLines <= 2)
    {
        needExpand = NO;
    }
    else
    {
        needExpand = YES;
    }
    [super setText:text];
}

@end
