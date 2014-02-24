//
//  MRBookNote.h
//  MediaReader
//
//  Created by 张 超 on 12-8-22.
//
//

#import <Foundation/Foundation.h>

@interface MRBookNote : NSObject
{
    NSUInteger      pid;
    NSString    *   sectionId;
    NSString    *   content;
    NSString    *   note;
    BOOL            isLocal;
}

@property (assign, nonatomic) NSUInteger      pid;
@property (retain, nonatomic) NSString    *   sectionId;
@property (retain, nonatomic) NSString    *   content;
@property (retain, nonatomic) NSString    *   note;
@property (assign, nonatomic) BOOL isLocal;

@end
