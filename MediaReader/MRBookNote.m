//
//  MRBookNote.m
//  MediaReader
//
//  Created by 张 超 on 12-8-22.
//
//

#import "MRBookNote.h"

@implementation MRBookNote

@synthesize pid;
@synthesize sectionId;
@synthesize note;
@synthesize content;
@synthesize isLocal;

- (void) dealloc
{
    KSRELEASE(sectionId);
    KSRELEASE(note);
    KSRELEASE(content);
    [super dealloc];
}

@end
