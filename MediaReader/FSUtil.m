
//
//  FSUtil.m
//  LiveSpace
//
//  Created by liushengjie on 7/4/10.
//  Copyright 2010 Kingsoft. All rights reserved.
//

#import "FSUtil.h"
#import <stdlib.h>
#import <string.h>

@implementation FSUtil

+(NSString*) lowerCaseExtension: (NSString*) strFileName
{
	NSString* strFileNameBody = [strFileName stringByDeletingPathExtension];
	NSString* strExt = [strFileName pathExtension];
	
	strExt = [strExt lowercaseString];
	
	strFileName = [strFileNameBody stringByAppendingPathExtension: strExt];
	return strFileName;
}

+(BOOL) isExist:(NSString*)strPath isDir:(BOOL)isDir
{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL bIsDir = NO;
	BOOL bExistDirOrFile = [fm fileExistsAtPath:strPath isDirectory:&bIsDir];
    
    if(!bExistDirOrFile) return NO;

	return (bIsDir == isDir);
}
+(BOOL)removePath:(NSString*)strPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath: strPath] == YES)
    {
        return [fm removeItemAtPath : strPath error:nil];
    }
    
    return NO;
}

+(BOOL) copyFile:(NSString*)fromPath toPath:(NSString*)toPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    return [fm copyItemAtPath:fromPath toPath:toPath error:nil];
}

+(BOOL) newFolder:(NSString *)strPath force:(BOOL)force
{
    if(force || ![FSUtil isExist:strPath isDir:YES])
    {
        return [FSUtil newFolder:strPath];
    }
	return NO;
}

+(BOOL) newFile:(NSString *)strPath force:(BOOL)force
{
    if(force || ![FSUtil isExist:strPath isDir:NO])
    {
        return [FSUtil newFile:strPath];
    }
	return NO;
}

+(BOOL) newFolder:(NSString *)strPath
{
	NSFileManager* fm = [NSFileManager defaultManager];
	return [fm createDirectoryAtPath: strPath withIntermediateDirectories: YES attributes: nil error: nil];
}

+(BOOL) newFile:(NSString *)strPath
{
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* strFolder = [strPath stringByDeletingLastPathComponent];
	[fm createDirectoryAtPath: strFolder withIntermediateDirectories: YES attributes: nil error: nil];
	
	return [fm createFileAtPath: strPath contents: nil attributes: nil];
}

+(NSOutputStream*) outputStreamToFileAtPath:(NSString *)strPath append:(BOOL)bAppend
{
    if(strPath==nil) return nil;
    
	[FSUtil newFile: strPath];
	return [NSOutputStream outputStreamToFileAtPath: strPath append: bAppend];
}


+(double) getDiskSpace
{
	NSString* mountPoints[] = {
		@"/",
		@"/private/var"
	};
	
	NSFileManager* fm = [NSFileManager defaultManager];
	
	double n = 0;
	for (int i = 0; i < sizeof(mountPoints)/sizeof(mountPoints[0]); i++)
	{
		NSDictionary* attr = [fm attributesOfFileSystemForPath: mountPoints[i] error: nil];
		if (attr == nil)
			continue;
		
		NSNumber* nPartSize = (NSNumber *)[attr objectForKey: NSFileSystemSize];
		n += [nPartSize doubleValue];
	}
	
	return n;
}

@end


double calc_dir_size_reclusive_lvl_2(NSString* path)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    double size = 0;
    
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size+= fileAttributeDic.fileSize;
            //DSLog(@"calc_dir_size_reclusive_lvl_2 [%@][%0.0f]",fullPath,size);
        }
        else
        {
            calc_dir_size_reclusive_lvl_2(fullPath);
        }
    }
    [fileManager release];
    
    [pool release];
    return size;
}

double calc_dir_size_reclusive_lvl_0(NSString* dirPath, NSFileManager* fm)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	double nTotalSize = 0;
	NSArray* dirNames = [fm contentsOfDirectoryAtPath: dirPath error: nil];
	
	for (NSString* dirName in dirNames)
	{
		NSString* dir = [dirPath stringByAppendingPathComponent: dirName];
		NSDictionary* attr = [fm attributesOfItemAtPath: dir error: nil];
		NSNumber* numberSize = [attr objectForKey:NSFileSize];
		nTotalSize += [numberSize integerValue];
	}
	
	[pool release];
	return nTotalSize;
}

// 获取当前目录及其第一级子目录的文件大小
double calc_dir_size_reclusive_lvl_1(NSString* dirPath, NSFileManager* fm)
{
	// !!! 内存占用 用Enum比 contentOfDirectoryAtPath的峰值占用多一些？
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	double nTotalSize = 0;
	NSArray* dirNames = [fm contentsOfDirectoryAtPath: dirPath error: nil];
	
	for (NSString* dirName in dirNames)
	{
		NSString* dir = [dirPath stringByAppendingPathComponent: dirName];
		nTotalSize += calc_dir_size_reclusive_lvl_0(dir, fm);
	}
	
	
	//	NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath: dirPath];
	//	if (dirEnum != nil)
	//	{
	//		for (NSString* dir in dirEnum)
	//		{
	//			NSString* strFullPath = [dirPath stringByAppendingPathComponent: dir];
	//			NSDictionary* attr = [fm attributesOfItemAtPath: strFullPath error: nil];
	//			// NSAssert(attr != nil, @"");
	//			nTotalSize += [attr fileSize];
	//		}
	//	}
	
	//	{
	//		KSLog(@"size of enum : %d\n", nTotalSize);
	//		NSDictionary* dict = [fm attributesOfItemAtPath:dirPath error:nil];
	//		NSNumber* numberSize = [dict objectForKey:NSFileSize];
	//		KSLog(@"size of attributes: %d\n", [numberSize integerValue]);
	//		
	//		dict = [fm attributesOfFileSystemForPath:dirPath error:nil];
	//		numberSize = [dict objectForKey:NSFileSystemSize];
	//		KSLog(@"size of attributes: %d\n", [numberSize integerValue]);
	//	}
	[pool release];
	return nTotalSize;
}


BOOL writeDataToFile(NSData* data, NSString* strFullPath)
{
	// Create containing folder
	NSString* strFolder = [strFullPath stringByDeletingLastPathComponent];
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath: strFolder withIntermediateDirectories: YES attributes: nil error: nil];
	
	// Write to file
	BOOL bResult = [data writeToFile: strFullPath atomically: YES];
	// NSAssert(bResult == YES, @"Can't write to file\n");
	
#ifdef _DEBUG	
	{
		NSString* strName = [strFullPath lastPathComponent];
		if (bResult == YES)
		{
			DSLog(@"File written: %@\n", strName);
		}
		else 
		{
			NSString* strName = [strFullPath lastPathComponent];
			DSLog(@"Write data to file failed: %@\n", strName);
		}
	}
#endif
	
	return bResult;
}
