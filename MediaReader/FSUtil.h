//
//  FSUtil.h
//  LiveSpace
//
//  Created by liushengjie on 7/4/10.
//  Copyright 2010 Kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSUtil : NSObject {

}

+(NSString*) lowerCaseExtension: (NSString*) strPath;

+(BOOL) isExist:(NSString*)strPath isDir:(BOOL)isDir;
+(BOOL) copyFile:(NSString*)fromPath toPath:(NSString*)toPath;

+(BOOL)removePath:(NSString*)strPath;

+(BOOL) newFolder:(NSString *)strPath force:(BOOL)force;
+(BOOL) newFile:(NSString *)strPath force:(BOOL)force;

+(BOOL) newFolder: (NSString*) strPath;
+(BOOL) newFile: (NSString*) strPath;
+(NSOutputStream*) outputStreamToFileAtPath: (NSString*) strPath append: (BOOL) bAppend;

+(double) getDiskSpace;

@end

double calc_dir_size_reclusive_lvl_2(NSString* dirPath);

double calc_dir_size_reclusive_lvl_0(NSString* dirPath, NSFileManager* fm);
double calc_dir_size_reclusive_lvl_1(NSString* dirPath, NSFileManager* fm);
BOOL writeDataToFile(NSData* data, NSString* strFullPath);