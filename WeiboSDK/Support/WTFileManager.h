//
//  WTFileManager.h
//  Weibo
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTFileManager : NSObject

+ (NSString *)createDirectoryIfNonExistent:(NSString *)path;
+ (NSString *)cachesDirectory;
+ (NSString *)documentsDirectory;
+ (NSString *)subCacheDirectory:(NSString *)name;
+ (NSString *)subDocumentsDirectory:(NSString *)name;
+ (NSString *)databaseCacheDirectory;

@end
