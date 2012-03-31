//
//  LocalAutocompleteDB.h
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboAutocompleteResultItem.h"

@class FMDatabase, WeiboUser, WeiboAccount;

@interface LocalAutocompleteDB : NSObject {
    FMDatabase * db;
}

@property (readonly, nonatomic) FMDatabase *db;

+ (void)verifyDatabase;
+ (NSString *)databasePath;
+ (LocalAutocompleteDB *)sharedAutocompleteDB;
+ (void)resetDatabase;
+ (void)shutdown;

#pragma mark -
#pragma mark Database Life Cycle
- (id)initWithPath:(NSString *)path;
- (void)close;
- (void)loadSchema;

#pragma mark - Accessor
- (BOOL)isReady;

#pragma mark - Data Fetching
- (void)seedAccount:(WeiboAccount *)account;
- (void)didReceiveFriends:(id)response info:(id)info;
- (void)loadFromDisk;
- (void)saveToDisk;
- (void)beginTransaction;
- (void)endTransaction;

#pragma mark - 
#pragma mark Data Access
- (void)addUser:(WeiboUser *)user;
- (void)addUsername:(NSString *)screenname avatarURL:(NSString *)url;
- (void)prioritizeUsername:(NSString *)screenname;
- (void)assimilateFromStatuses:(NSArray *)statuses;
- (void)compact;

- (NSArray *)defaultResultsForType:(WeiboAutocompleteType)type;
- (NSArray *)resultsForPartialText:(NSString *)text type:(WeiboAutocompleteType)type;
@end
