//
//  LocalAutocompleteDB.m
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "LocalAutocompleteDB.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "WTFoundationUtilities.h"
#import "WTFileManager.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "WeiboBaseStatus.h"
#import "sqlite3.h"

static LocalAutocompleteDB * sharedDB = nil;

@implementation LocalAutocompleteDB
@synthesize db;

+ (NSString *)databasePath{
    NSString * databaseCacheDirectory = [WTFileManager databaseCacheDirectory];
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
    [sharedDB release];
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
- (id)init{
    return [self initWithPath:[[self class] databasePath]];
}
- (id)initWithPath:(NSString *)path{
    if (self = [super init]) {
        db = [[FMDatabase databaseWithPath:path] retain];
        if (![db open]) {
            [db release];
            return nil;
        }
    }
    return self;
}
- (void)dealloc{
    [self close];
    [super dealloc];
}
- (void)close{
    [db close];
}
- (void)loadSchema{
    NSString * filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/autocomplete_schema.sql"];
    NSString * schema = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    sqlite3 * sqliteDB = [db sqliteHandle];
    sqlite3_exec(sqliteDB, [schema UTF8String], NULL, NULL, NULL);
    [schema release];
}

#pragma mark - Accessor
- (BOOL)isReady{
    return [db tableExists:@"names"];
}

#pragma mark - Data Fetching
- (void)seedAccount:(WeiboAccount *)account{
}
- (void)didReceiveFriends:(id)response info:(id)info{
}
- (void)loadFromDisk{
    
}
- (void)saveToDisk{
    
}

#pragma mark - 
#pragma mark Data Access
- (void)beginTransaction
{
    [db beginTransaction];
}
- (void)endTransaction
{
    [db commit];
}
- (void)addUser:(WeiboUser *)user
{
    [self addUserID:user.userID username:user.screenName avatarURL:user.profileImageUrl];
}
- (void)addUserID:(WeiboUserID)userID username:(NSString *)screenname avatarURL:(NSString *)url
{
    NSString * ID = [NSString stringWithFormat:@"%lld",userID];
    NSNumber * priority = [NSNumber numberWithInteger:1];
    NSString * username = screenname;
    NSString * fullname = [self stylizedPinyinFromString:screenname];
    NSString * avatar_url = url;
    NSNumber * updated_at = [NSNumber numberWithInteger:[[NSDate date] 
                                                        timeIntervalSince1970]];
    [db executeUpdate:@"insert or replace into names values (?,?,?,?,?,?)",ID,priority,username,fullname,avatar_url,updated_at];
}
- (void)addUsers:(NSArray *)users
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul);
    dispatch_async(queue, ^{
        NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
        [self beginTransaction];
        for (WeiboUser * user in users)
        {
            if (user.screenName && ![userDict valueForKey:user.screenName])
            {
                [userDict setValue:@"" forKey:user.screenName];
                [self addUser:user];
            }
        }
        [self endTransaction];
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
- (void)prioritizeUsername:(NSString *)screenname
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
    if (![self isReady]) {
        return nil;
    }
    NSMutableArray * resultArray = [NSMutableArray array];
    NSString * pattern = [[text stringByAppendingString:@"%"] lowercaseString];
    FMResultSet *rs = [db executeQuery:@"select * from names where id like ? or full_name like ? or username like ? order by full_name asc",pattern,pattern,pattern];
    while ([rs next]) {
        WeiboAutocompleteResultItem * item = [[WeiboAutocompleteResultItem alloc] init];
        [item setPriority:[rs intForColumn:@"priority"]];
        [item setAutocompleteText:[rs stringForColumn:@"username"]];
        [item setAutocompleteSubtext:[rs stringForColumn:@"full_name"]];
        NSURL * avatarURL = [NSURL URLWithString:[rs stringForColumn:@"avatar_url"]];
        [item setAutocompleteImageURL:avatarURL];
        [item setItemID:[rs stringForColumn:@"id"]];
        [resultArray addObject:item];
        [item release];
    }
    [rs close];
    return [NSArray arrayWithArray:resultArray];
}

@end
