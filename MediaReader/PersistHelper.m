//
//  PersistMacros.m
//  LiveSpace
//
//  Created by zhujian on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PersistHelper.h"


@implementation PersistHelper

+ (void) persistSaveInteger : (id) object ofProperty : (SEL) propertyItem toDictionary : dictionary forKey : (NSString*) key
{
	NSInteger value = (NSInteger)[object performSelector:propertyItem];
	NSString* str = [NSString stringWithFormat : @"%d", value];
	[dictionary setObject : str forKey : key];
}
@end
