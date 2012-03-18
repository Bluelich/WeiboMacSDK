//
//  LocalAutocompleteDB.m
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "LocalAutocompleteDB.h"
#import "FMDatabase.h"
#import "WTFoundationUtilities.h"

static LocalAutocompleteDB * sharedDB = nil;

@implementation LocalAutocompleteDB
@synthesize db;

+ (void)verifyDatabase{
    WeiboUnimplementedMethod
}
+ (NSString *)databasePath{
    NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * databasePath = [[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"AutocompleteDB"];
    return databasePath;
}
+ (LocalAutocompleteDB *)sharedAutocompleteDB{
    if (sharedDB) {
        sharedDB = [[[self class] alloc] init];
    }
    return sharedDB;
}
+ (void)resetDatabase{
    WeiboUnimplementedMethod
}
+ (void)shutdown{
    [[self sharedAutocompleteDB] close];
    [[self sharedAutocompleteDB] release];
}

#pragma mark -
#pragma mark Database Life Cycle
- (id)init{
    if (self = [super init]) {
        db = [FMDatabase databaseWithPath:[[self class] databasePath]];
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
    [db release];
}

@end
