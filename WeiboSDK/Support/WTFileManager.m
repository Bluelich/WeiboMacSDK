//
//  WTFileManager.m
//  Weibo
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTFileManager.h"
#import "WeiboConstants.h"

@implementation WTFileManager

+ (NSString *)createDirectoryIfNonExistent:(NSString *)directory{
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager]; 
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", directory);
    return directory;
}
+ (NSString *)cachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES) objectAtIndex:0];
}
+ (NSString *)documentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
}
+ (NSString *)subCacheDirectory:(NSString *)name{
    NSString * path = [[[self cachesDirectory] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:name];
    return [self createDirectoryIfNonExistent:path];
}
+ (NSString *)subDocumentsDirectory:(NSString *)name{
    NSString * path = [[[self documentsDirectory] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:name];
    return [self createDirectoryIfNonExistent:path];
}
+ (NSString *)databaseCacheDirectory{
    return [self subCacheDirectory:@"AutoCompleteDB"];
}
+ (BOOL)fileExist:(NSString *)path{
    NSFileManager *fileManager= [NSFileManager defaultManager]; 
    return [fileManager fileExistsAtPath:path];
}

@end
