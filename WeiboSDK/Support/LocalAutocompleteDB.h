//
//  LocalAutocompleteDB.h
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface LocalAutocompleteDB : NSObject {
    FMDatabase * db;
}

@property (readonly, nonatomic) FMDatabase *db;

+ (void)verifyDatabase;
+ (NSString *)databasePath;
+ (LocalAutocompleteDB *)sharedAutocompleteDB;
+ (void)resetDatabase;
+ (void)shutdown;

@end
