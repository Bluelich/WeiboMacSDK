//
//  WeiboUserUserList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserUserList.h"
#import "WTCallback.h"
#import "WeiboRequestError.h"
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

@property (nonatomic, retain) NSMutableArray * users;
@property (nonatomic, assign) WeiboUserID cursor;

@end

@implementation WeiboUserUserList
@synthesize users = _users;

- (void)dealloc
{
    [_users release], _users = nil;
    [_user release], _user = nil;
    [_account release], _account = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        self.users = [NSMutableArray array];
    }
    return self;
}

- (void)_loadOlder
{
    
}
- (void)loadOlder
{
    if (!_flags.isLoading)
    {
        [self _loadOlder];
        
        _flags.isLoading = YES;
    }
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

- (WTCallback *)usersListCallbackWithCursor:(WeiboUserID)cursor
{
    NSNumber * info = cursor ? @(cursor) : nil;
    
    return WTCallbackMake(self, @selector(_usersResponse:info:), info);
}

- (void)_usersResponse:(id)response info:(id)info
{
    _flags.isLoading = NO;
    
    if (![response isKindOfClass:[NSDictionary class]])
    {
        if ([response isKindOfClass:[WeiboRequestError class]])
        {
            [self didReceiveRequestError:response];
        }
        return;
    }
    
    NSArray * users = [response objectForKey:@"users"];
    
    if (!users || ![users isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    BOOL loadingNew = (self.users.count && [info isKindOfClass:[NSNumber class]]);
    
    if (!loadingNew)
    {
        self.cursor = [response longlongForKey:@"next_cursor" defaultValue:0];
    }
    
    [self _addUsers:users loadingNew:loadingNew];
}

- (void)_addUsers:(NSArray *)newUsers loadingNew:(BOOL)loadingNew
{
    NSMutableArray * toAdd = [[newUsers mutableCopy] autorelease];
    
    [toAdd removeObjectsInArray:_users];
    
    if (loadingNew)
    {
        NSIndexSet * set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, toAdd.count)];
        [_users insertObjects:toAdd atIndexes:set];
    }
    else
    {
        [_users addObjectsFromArray:toAdd];
    }
    
    [self didAddUsers:toAdd prepend:loadingNew];
}

@end
