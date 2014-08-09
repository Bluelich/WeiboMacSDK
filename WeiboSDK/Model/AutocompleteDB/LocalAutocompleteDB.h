//
//  LocalAutocompleteDB.h
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboAutocompleteResultItem.h"

@class WeiboUser, WeiboAccount;

@interface LocalAutocompleteDB : NSObject

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
- (BOOL)accountSeeded:(WeiboAccount *)account;
- (void)seedAccount:(WeiboAccount *)account;

#pragma mark - 
#pragma mark Data Access
- (void)addUser:(WeiboUser *)user;
- (void)addUsers:(NSArray *)users;
- (void)assimilateFromStatuses:(NSArray *)statuses;

- (NSArray *)defaultResultsForType:(WeiboAutocompleteType)type;
- (NSArray *)resultsForPartialText:(NSString *)text type:(WeiboAutocompleteType)type;
- (NSArray *)resultsForPartialText:(NSString *)text serverMentionSuggestionJSONArray:(NSArray *)suggestions;

@end
