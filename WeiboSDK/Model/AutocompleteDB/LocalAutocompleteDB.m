//
//  LocalAutocompleteDB.m
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "LocalAutocompleteDB.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "WeiboFoundationUtilities.h"
#import "WeiboFileManager.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "WeiboBaseStatus.h"
#import "sqlite3.h"
#import "WeiboCallback.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboUserMentionSuggestion.h"
#import <NSDictionary+Accessors.h>

static LocalAutocompleteDB * sharedDB = nil;

@interface LocalAutocompleteDB ()

@property (nonatomic, strong) FMDatabaseQueue * dbQueue;

@end

@implementation LocalAutocompleteDB

+ (NSString *)databasePath{
    NSString * databaseCacheDirectory = [WeiboFileManager databaseCacheDirectory];
    NSString * databasePath = [databaseCacheDirectory stringByAppendingPathComponent:@"AutocompleteDB.sqlite3"];
    return databasePath;
}
+ (LocalAutocompleteDB *)sharedAutocompleteDB
{
    if (!sharedDB)
    {
        sharedDB = [[[self class] alloc] init];
        
        if (![sharedDB isReady])
        {
            [sharedDB loadSchema];
        }
    }
    
    return sharedDB;
}
+ (void)resetDatabase
{
    [self shutdown];
    sharedDB = nil;
    NSString * path = [self databasePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    NSLog(@"Path to file: %@", path);        
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:path]);
    if (fileExists) 
    {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}
+ (void)shutdown
{
    [[self sharedAutocompleteDB] close];
    // NO need to release singleton
    //[[self sharedAutocompleteDB] release];
}

#pragma mark -
#pragma mark Database Life Cycle

- (void)dealloc
{
    [self close];
    _dbQueue = nil;
    
}
- (void)close
{
    [self.dbQueue close];
}

- (id)init
{
    return [self initWithPath:[[self class] databasePath]];
}
- (id)initWithPath:(NSString *)path
{
    if (self = [super init])
    {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}
- (void)loadSchema
{
    NSURL * schemaURL = [[NSBundle mainBundle] URLForResource:@"WeiboSDKResources/autocomplete_schema" withExtension:@"sql"];
    
    if (!schemaURL)
    {
        return;
    }
    
    NSString * schema = [[NSString alloc] initWithContentsOfURL:schemaURL encoding:NSUTF8StringEncoding error:nil];
    
    dispatch_async_background(^{
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            sqlite3 * sqliteDB = [db sqliteHandle];
            sqlite3_exec(sqliteDB, [schema UTF8String], NULL, NULL, NULL);
        }];
    });
}

#pragma mark - Accessor
- (BOOL)isReady
{
    __block BOOL result = NO;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db tableExists:@"names"];
        
    }];

    return result;
}

#pragma mark - Data Fetching

- (NSString *)accountSeedUserDefaultsKeyForUserID:(WeiboUserID)userID
{
    return [NSString stringWithFormat:@"friends_seeded_%lld", userID];
}

- (BOOL)accountSeeded:(WeiboAccount *)account
{
    NSString * key = [self accountSeedUserDefaultsKeyForUserID:account.user.userID];
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
- (void)setSeededForAccount:(WeiboAccount *)account
{
    NSString * key = [self accountSeedUserDefaultsKeyForUserID:account.user.userID];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

- (void)seedAccount:(WeiboAccount *)account
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(didReceiveFriends:info:), account);
    WeiboAPI * api = [account authenticatedRequest:callback];
    
    [api bilateralFriendsForUserID:account.user.userID count:200 page:1];
}
- (void)didReceiveFriends:(id)responseObject info:(id)info
{
    if ([responseObject isKindOfClass:[WeiboRequestError class]])
    {
        
    }
    else if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        [self setSeededForAccount:info];
        [self addUsers:responseObject[@"users"]];
    }
}
- (void)loadFromDisk
{
    
}
- (void)saveToDisk
{
    
}

#pragma mark - 
#pragma mark Data Access

- (void)addUser:(WeiboUser *)user
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [self _addUser:user inDatabase:db];
        
    }];
}

- (void)_addUser:(WeiboUser *)user inDatabase:(FMDatabase *)db
{
    [self addUserID:user.userID username:user.screenName avatarURL:user.profileImageUrl database:db];
}

- (void)addUserID:(WeiboUserID)userID username:(NSString *)screenname avatarURL:(NSString *)url database:(FMDatabase *)db
{
    NSString * ID = [NSString stringWithFormat:@"%lld",userID];
    NSNumber * priority = [NSNumber numberWithInteger:1];
    NSString * username = screenname;
    NSString * fullname = [self stylizedPinyinFromString:screenname];
    NSString * avatar_url = url;
    NSNumber * updated_at = @([[NSDate date] timeIntervalSince1970]);
    
    [db executeUpdate:@"insert or replace into names values (?,?,?,?,?,?)",ID,priority,username,fullname,avatar_url,updated_at];
}
- (void)addUsers:(NSArray *)users
{
    if (!users.count) return;
    
    dispatch_async_low(^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback __attribute__((unused))) {
            
            for (WeiboUser * user in users)
            {
                NSMutableSet * derepeater = [NSMutableSet set];

                if (user.screenName && ![derepeater containsObject:user.screenName])
                {
                    [derepeater addObject:user.screenName];
                    
                    [self _addUser:user inDatabase:db];
                }
            }
            
        }];
    });
}
- (NSString *)stylizedPinyinFromString:(NSString *)string
{
    NSMutableString * mString = [NSMutableString stringWithString:string];
    NSRange range = NSMakeRange(0, [mString length]);
    CFStringTransform((CFMutableStringRef)mString, (CFRange *)&range, 
                      CFSTR("Any - Latin; NFD; [:Nonspacing Mark:] Remove; [:Whitespace:] Remove; Lower; NFC;"), NO);
    NSString * fullpinyin = [mString uppercaseString];
    return [fullpinyin substringToIndex:[fullpinyin length] > 16?16:[fullpinyin length]];
}
- (void)prioritizeUsername:(NSString * __attribute__((unused)))screenname
{
    WeiboUnimplementedMethod
}
- (void)assimilateFromStatuses:(NSArray *)statuses
{
    NSMutableArray * users = [NSMutableArray array];
    
    for (WeiboBaseStatus * status in statuses)
    {
        if (status.user)
        {
            [users addObject:status.user];
        }
    }
    
    [self addUsers:users];
}
- (void)compact
{
    
}


- (NSArray *)defaultResultsForType:(WeiboAutocompleteType)type
{
    return [self resultsForPartialText:@"" type:type];
}
- (NSArray *)resultsForPartialText:(NSString *)text type:(WeiboAutocompleteType)type
{
    if (![self isReady])
    {
        return nil;
    }
    
    NSMutableArray * resultArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * pattern = [[text stringByAppendingString:@"%"] lowercaseString];
        FMResultSet *rs = [db executeQuery:@"select * from names where id like ? or full_name like ? or username like ? order by full_name asc",pattern,pattern,pattern];
        while ([rs next]) {
            WeiboAutocompleteResultItem * item = [[WeiboAutocompleteResultItem alloc] init];
            [item setPriority:[rs intForColumn:@"priority"]];
            [item setAutocompleteText:[rs stringForColumn:@"username"]];
            //[item setAutocompleteSubtext:[rs stringForColumn:@"full_name"]];
            NSURL * avatarURL = [NSURL URLWithString:[rs stringForColumn:@"avatar_url"]];
            [item setAutocompleteImageURL:avatarURL];
            [item setItemID:[rs stringForColumn:@"id"]];
            [item setAutocompleteType:type];
            [resultArray addObject:item];
        }
        [rs close];
        
    }];
    
    return [NSArray arrayWithArray:resultArray];
}

- (NSArray *)autoCompleteItemsWithMentionSuggestionJSONArray:(NSArray *)array
{
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSDictionary * dict in array)
    {
        WeiboAutocompleteResultItem * item = [[WeiboAutocompleteResultItem alloc] init];

        item.itemID = [dict stringForKey:@"uid"];
        item.autocompleteText = [dict stringForKey:@"nickname"] ? : @"";
        item.autocompleteSubtext = [dict stringForKey:@"remark"] ? : @"";
        item.autocompleteType = WeiboAutocompleteTypeUser;
        
        if (item.itemID.length)
        {
            [result addObject:item];
        }
        
    }
    
    return result;
}

- (NSArray *)resultsForPartialText:(NSString *)text serverMentionSuggestionJSONArray:(NSArray *)suggestionJSONArray
{
    NSMutableArray * results = [[self resultsForPartialText:text type:WeiboAutocompleteTypeUser] mutableCopy];
    
    if ([suggestionJSONArray isKindOfClass:[NSArray class]] && suggestionJSONArray.count)
    {
        NSArray * localItems = [self autoCompleteItemsWithMentionSuggestionJSONArray:suggestionJSONArray];
        
        for (WeiboAutocompleteResultItem * item in localItems)
        {
            NSUInteger existIdx = [results indexOfObject:item];
            if (existIdx != NSNotFound)
            {
                WeiboAutocompleteResultItem * exist = results[existIdx];
                item.autocompleteImageURL = exist.autocompleteImageURL;
                
                [results removeObjectAtIndex:existIdx];
            }
        }
        
        [results insertObjects:localItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, localItems.count)]];
    }
    
    return results;
}

@end
