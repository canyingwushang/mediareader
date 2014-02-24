//
//  MRFileSystem.h
//  MediaReader
//
//  Created by jinbo he on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRFileSystem : NSObject

- (void) initFileSystem;
- (BOOL) deleteBookMarkList:(NSUInteger)pid Page:(NSUInteger) pagenum;
- (void) insertBackupRecord:(NSUInteger)pid Page:(NSUInteger) pagenum;
- (NSArray*) queryBookmarkList;
- (BOOL) checkBookmarkExist: (NSUInteger) pid Page:(NSUInteger) pagenum;

- (void) insertBookNote:(NSUInteger)pId Section:(NSString *)sectionId BookContent:(NSString *) content Note:(NSString *) note;
- (void) deleteBookNote:(NSString *)sectionId Note:(NSString *)note;
- (NSArray*) queryBooknoteList:(NSUInteger) pid;
@end
