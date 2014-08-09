//
//  WeiboUserUserList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserUserList.h"
#import "WeiboCallback.h"
#import "WeiboRequestError.h"
#import "Weibo.h"
#import "NSDictionary+WeiboAdditions.h"

NSString * const WeiboUserUserListDidAddUsersNotification = @"WeiboUserUserListDidAddUsersNotification";
NSString * const WeiboUserUserListDidReceiveRequestErrorNotification = @"WeiboUserUserListDidReceiveRequestErrorNotification";

NSString * const WeiboUserUserListDidAddUserNotificationPrependKey = @"WeiboUserUserListDidAddUserNotificationPrependKey";
NSString * const WeiboUserUserListDidAddUserNotificationUsersKey = @"WeiboUserUserListDidAddUserNotificationUsersKey";
NSString * const WeiboUserUserListNotificationRequestErrorKey = @"WeiboUserUserListNotificationRequestErrorKey";


@interface WeiboUserUserList ()
{
    struct {
        unsigned int isLoading: 1;
        unsigned int isAtEnd: 1;
    } _flags;
}

@property (nonatomic, strong) NSMutableArray * users;
@property (nonatomic, assign) WeiboUserID cursor;

@end

@implementation WeiboUserUserList
@synthesize users = _users;

- (void)dealloc
{
    _users = nil;
    _user = nil;
    _account = nil;
}

- (id)init
{
    if (self = [super init])
    {
        self.users = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        WeiboUserID userID = (WeiboUserID)[aDecoder decodeInt64ForKey:@"account_id"];
        self.account = [[Weibo sharedWeibo] accountWithUserID:userID];
        
        if (!self.account) return nil;
        
        self.user = [aDecoder decodeObjectForKey:@"user"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInt64:(int64_t)self.account.user.userID forKey:@"account_id"];
    [aCoder encodeObject:self.user forKey:@"user"];
}

- (void)_loadOlder
{
    
}
- (void)loadOlder
{
    if (_flags.isAtEnd)
    {
        return;
    }
    
    if (!_flags.isLoading)
    {
        [self _loadOlder];
        
        _flags.isLoading = YES;
    }
}
- (void)retryLoadOlder
{
    _flags.isAtEnd = NO;
    
    [self loadOlder];
}
- (void)_loadNewer
{
    
}
- (void)loadNewer
{
    if (!_flags.isLoading)
    {
        [self _loadNewer];
        
        _flags.isLoading = YES;
    }
}

- (void)markAtEnd
{
    _flags.isAtEnd = YES;
}
- (BOOL)isEnded
{
    return _flags.isAtEnd;
}

- (void)didAddUsers:(NSArray *)users prepend:(BOOL)prepend
{
    NSDictionary * userInfo = @{WeiboUserUserListDidAddUserNotificationPrependKey : @(prepend),
                                WeiboUserUserListDidAddUserNotificationUsersKey : users};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUserUserListDidAddUsersNotification object:self userInfo:userInfo];
}
- (void)didReceiveRequestError:(WeiboRequestError *)error
{
    NSDictionary * userInfo = @{WeiboUserUserListNotificationRequestErrorKey : error};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUserUserListDidReceiveRequestErrorNotification object:self userInfo:userInfo];
}

- (NSArray *)users
{
    return _users;
}

- (WeiboCallback *)usersListCallbackWithLoadingNewer:(BOOL)loadingNewer
{
    NSNumber * info = loadingNewer ? @(YES) : nil;
    
    return WeiboCallbackMake(self, @selector(_usersResponse:info:), info);
}

- (void)_usersResponse:(id)response info:(id)info
{
    _flags.isLoading = NO;
    
    BOOL loadingNew = !(self.users.count && ![info isKindOfClass:[NSNumber class]]);
    
    BOOL errorLoading = NO;
    
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        errorLoading = YES;
    }
    
    if (loadingNew)
    {
        self.loadNewerError = errorLoading ? response : nil;
    }
    else
    {
        self.loadOlderError = errorLoading ? response : nil;
    }

    if (errorLoading)
    {
        if (!loadingNew || !self.users.count)
        {
            [self markAtEnd];
        }
        
        [self didReceiveRequestError:response];
        
        return;
    }
    
    NSArray * users = response;
    
    if (!users || ![users isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    WeiboUserID cursor = (WeiboUserID)[[users weibo_serverMetaData] longlongForKey:@"next_cursor" defaultValue:0];
    NSInteger totalCount = [[users weibo_serverMetaData] intForKey:@"total_number" defaultValue:0];
    
    if (cursor)
    {
        self.cursor = cursor;
    }
    
    [self _addUsers:users loadingNew:loadingNew totalCount:totalCount];
}

- (void)_addUsers:(NSArray *)newUsers loadingNew:(BOOL)loadingNew totalCount:(NSInteger)totalCount
{
    NSMutableArray * toAdd = [newUsers mutableCopy];
    
    for (WeiboUser * user in _users)
    {
        [toAdd removeObject:user];
    }
    
    if (!toAdd.count)
    {
        if (!_users.count ||
            !loadingNew)
        {
            [self markAtEnd];
        }
    }
    
    if (loadingNew)
    {
        NSIndexSet * set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, toAdd.count)];
        [_users insertObjects:toAdd atIndexes:set];
    }
    else
    {
        [_users addObjectsFromArray:toAdd];
    }
    
    if (_users.count == (NSUInteger)totalCount)
    {
        [self markAtEnd];
    }
    
    [self didAddUsers:toAdd prepend:loadingNew];
}

@end
