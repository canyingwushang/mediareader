//
//  KSTip.h
//  LiveSpace
//
//  Created by lidong wang on 12-6-7.
//  Copyright (c) 2012年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSProgress.h"

@interface KSTip : NSObject
{
    KSProgress* _tipView;
}

-(void)hide:(BOOL)animated;

-(void)hide;
- (void)showInView:(UIView*)view withText:(NSString*)text;
- (void)showInView:(UIView*)view withText:(NSString*)text imageName:(NSString *)name;


+(KSTip *) shareTip;


@end
