//
//  PersistMacros.h
//  LiveSpace
//
//  Created by zhujian on 10/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PersistHelper : NSObject
{
	// 此类仅用于实现persist相关的全局函数
}
+ (void) persistSaveInteger : (id) object ofProperty : (SEL) propertyItem toDictionary : dictionary forKey : (NSString*) key;

@end
/* 
 处理plist文件相关的宏
 */

#define PERSIST_LOAD_ITEM_NSInteger(object, item, dictionary, defaultValue) \
do{																			\
NSInteger value = (defaultValue);										\
if (nil != dictionary)													\
{																		\
NSString* str = [dictionary objectForKey : @#item];					\
if (nil != str)														\
{																	\
value = [str intValue];											\
if (value == INT_MAX || value == INT_MIN)						\
value = (defaultValue);										\
}																	\
}																		\
object.item = value;													\
}while(0)															

#define PERSIST_SAVE_ITEM_NSInteger(object, item, dictionary)				\
[PersistHelper persistSaveInteger : object ofProperty : @selector(item) toDictionary : dictionary forKey : @#item];

#define PERSIST_LOAD_ITEM_CGPoint(object, item, dictionary, defaultValue)	\
do{																			\
CGPoint value = (defaultValue);											\
if (nil != dictionary)													\
{																		\
NSString* strx = [dictionary objectForKey : @#item".x"];			\
if (nil != strx)													\
{																	\
value.x = [strx floatValue];									\
if (value.x == HUGE_VAL || value.x == -HUGE_VAL || value.x == 0)\
value.x = (defaultValue.x);									\
}																	\
NSString* stry = [dictionary objectForKey : @#item".y"];			\
if (nil != stry)													\
{																	\
value.y = [stry floatValue];									\
if (value.y == HUGE_VAL || value.y == -HUGE_VAL || value.y == 0)\
value.y = (defaultValue.y);									\
}																	\
}																		\
object.item = value;													\
}while(0)															

#define PERSIST_SAVE_ITEM_CGPoint(object, item, dictionary)					\
do{																			\
NSString* strx = [NSString stringWithFormat : @"%f", (object.item.x)];	\
[dictionary setObject : strx forKey : @#item".x"];						\
NSString* stry = [NSString stringWithFormat : @"%f", (object.item.x)];	\
[dictionary setObject : stry forKey : @#item".y"];						\
}while(0)
