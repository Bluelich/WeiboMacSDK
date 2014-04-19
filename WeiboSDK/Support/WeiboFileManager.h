//
//  WeiboFileManager.h
//  Weibo
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboFileManager : NSObject

+ (NSString *)createDirectoryIfNonExistent:(NSString *)path;
+ (NSString *)cachesDirectory;
+ (NSString *)cachesApplicationDirectory;

+ (NSString *)applicationSupportDirectory;
+ (NSString *)applicationSupportApplicationDirectory;
+ (NSString *)subApplicationSupportDirectory:(NSString *)name;

+ (NSString *)documentsDirectory;
+ (NSString *)documentsApplicationDirectory;
+ (NSString *)subCacheDirectory:(NSString *)name;
+ (NSString *)subDocumentsDirectory:(NSString *)name;
+ (NSString *)databaseCacheDirectory;
+ (BOOL)fileExist:(NSString *)path;

@end
