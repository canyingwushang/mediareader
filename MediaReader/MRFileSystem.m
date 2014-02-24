//
//  MRFileSystem.m
//  MediaReader
//
//  Created by jinbo he on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MRFileSystem.h"
#import "FSUtil.h"
#import "FMDatabase.h"
#import "MRBookNote.h"

@interface  MRFileSystem()
{
    NSString * cacheSqliteFile;
}

@property (retain, nonatomic) NSString * cacheSqliteFile;

@end

@implementation MRFileSystem

@synthesize cacheSqliteFile;

- (void) dealloc
{
    self.cacheSqliteFile = nil;
    [super dealloc];
}

- (void) initFileSystem
{
    [self createBookMarkList];
    [self createBookNoteList];
}

- (NSString*) _getUserSqliteFile
{
    DSLog(@"_getUserSqliteFile ");
    if(self.cacheSqliteFile == nil)
    {
        self.cacheSqliteFile = [self _getLocalCacheFile:@"usercache.sqlite" isCreate:YES];
    }
    return self.cacheSqliteFile;
}

- (NSString*) _getLocalCacheFile:(NSString*)_path isCreate:(BOOL)isCreate
{
    NSString* path = [NSString stringWithFormat:@"%@/%@",[self _getLibraryCachePath],_path];
    DSLog(@"%@", path);
    if(isCreate)
    {
        [FSUtil newFile:path force:NO];
    }
    return path;
}

#define kUserDataRootPath @"/Library/.userfiles"
- (NSString*) _getLibraryCachePath
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:kUserDataRootPath];
    [FSUtil newFolder:filePath force:NO];
    
    DSLog(@"getLibraryCachePath is %@",filePath);
    return filePath;
}

/***************************************************************************
 以数据库方式对书签进行管理
 **************************************************************************/

- (void) createBookMarkList
{
    DSLog(@"createBookMarkList");
	NSString* strPath = [self _getUserSqliteFile];
	if(nil==strPath) return;
    
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
    {
        if ([db hadError])
            DSLog(@"open SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return;
    }
	
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    [db beginTransaction];
	[db executeUpdate: @"CREATE TABLE IF NOT EXISTS tableBookmarkList (pId INTEGER, pagenum INTEGER, modifyTime DOUBLE)"];
	[db commit];
	[db close];
}

- (BOOL) deleteBookMarkList:(NSUInteger)pid Page:(NSUInteger) pagenum
{
    NSString* strPath = [self _getUserSqliteFile];
	if(nil==strPath) return NO;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
		return NO;
    
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    [db beginTransaction];
    [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tableBookmarkList WHERE pId = %d and pagenum = %d", pid, pagenum]];
    [db commit];
    [db close];
    
    return YES;
}

- (void) insertBackupRecord:(NSUInteger )pid Page:(NSUInteger) pagenum
{
	NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
    {
        if ([db hadError])
            DSLog(@"open SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return;
	}
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    if(pid > 0 && pagenum > 0){
        [db beginTransaction];
        [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tableBookmarkList WHERE pId = %d and pagenum = %d", pid, pagenum]];
        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO tableBookmarkList(pId, pagenum, modifyTime) values(%d,%d, %f)",
                           pid, pagenum, [[NSDate date] timeIntervalSince1970]]];
        [db commit];
    }
	[db close];
    
}


- (NSArray*) queryBookmarkList
{
    NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return nil;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
		return nil;
	
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    //int count = 0;
    NSMutableArray* arr = [[[NSMutableArray alloc]init]autorelease];
    
    FMResultSet* rs = [db executeQuery:@"SELECT * FROM tableBookmarkList"];
    
    while ([rs next]) 
    {    
        NSString* pid = [rs stringForColumn:@"pid"];
        NSUInteger pagenum = [[rs stringForColumn:@"pagenum"] intValue];
        if(pid.length>0 && pagenum>0)
        {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
            [dic setObject:pid forKey:@"pid"];
            [dic setObject:[NSNumber numberWithInt:pagenum] forKey:@"pagenum"];
            [arr addObject:dic];
            [dic release];
        }        
    }
    [rs close];
	[db close];
    
    return arr;
}

- (BOOL) checkBookmarkExist: (NSUInteger) pid Page:(NSUInteger) pagenum
{
    NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return NO;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
		return NO;
	
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    FMResultSet* rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tableBookmarkList where pid = %d and pagenum = %d", 
                                        pid, pagenum]];
    BOOL isExist = NO;
    while ([rs next]) 
    {    
        NSString* pid = [rs stringForColumn:@"pid"];
        NSUInteger pagenum = [[rs stringForColumn:@"pagenum"] intValue];
        if(pid.length>0 && pagenum>0)
        {
            isExist = YES;
        }        
    }
    [rs close];
	[db close];
    
    return isExist;
}

/***************************************************************************
 以数据库方式对笔记进行管理
 **************************************************************************/

- (void) createBookNoteList
{
    DSLog(@"createBookNoteList");
	NSString* strPath = [self _getUserSqliteFile];
	if(nil==strPath) return;
    
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
    {
        if ([db hadError])
            DSLog(@"open SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return;
    }
	
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    [db beginTransaction];
	[db executeUpdate: @"CREATE TABLE IF NOT EXISTS tableBooknoteList (pId INTEGER,sectionId TEXT, book TEXT, content TEXT, note TEXT, modifyTime DOUBLE)"];
	[db commit];
	[db close];
}

- (void) deleteBookNote:(NSString *)sectionId Note:(NSString *)note
{
	NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
    {
        if ([db hadError])
            DSLog(@"open SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return;
	}
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    if(sectionId != nil){
        [db beginTransaction];
        [db executeUpdate:[NSString stringWithFormat:@"delete from tableBooknoteList where sectionId = '%@' and note = '%@'", sectionId, note]];
        [db commit];
    }
	[db close];
}

- (void) insertBookNote:(NSUInteger)pId Section:(NSString *)sectionId BookContent:(NSString *) content Note:(NSString *) note
{
	NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
    {
        if ([db hadError])
            DSLog(@"open SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return;
	}
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    if(sectionId != nil && note != nil){
        [db beginTransaction];
        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO tableBooknoteList(pId, sectionId, content, note, modifyTime) values(%d,'%@','%@','%@', %f)", pId,sectionId, content, note, [[NSDate date] timeIntervalSince1970]]];
        [db commit];
    }
	[db close];
    
}

- (NSArray*) queryBooknoteList:(NSUInteger) pid
{
    NSString* strPath = [self _getUserSqliteFile];
    if(nil==strPath) return nil;
	FMDatabase* db = [FMDatabase databaseWithPath: strPath];
	if (![db open])
		return nil;
	
#ifdef _DEBUG
	db.logsErrors = YES;
#endif
	
	if ([db hadError])
		DSLog(@"SQLITE Error: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    //int count = 0;
    NSMutableArray* arr = [[[NSMutableArray alloc] init] autorelease];
    
    FMResultSet* rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tableBooknoteList where pId = %d", pid]];
    
    while ([rs next])
    {
        MRBookNote * temp = [[MRBookNote alloc] init];
        temp.pid = pid;
        temp.sectionId = [rs stringForColumn:@"sectionId"];
        temp.content = [rs stringForColumn:@"content"];
        temp.note = [rs stringForColumn:@"note"];
        temp.isLocal = YES;
        [arr insertObject:temp atIndex:0];
        [temp release];
    }
    [rs close];
	[db close];
    
    return arr;
}

@end
