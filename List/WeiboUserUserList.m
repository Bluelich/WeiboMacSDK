//
//  WeiboUserUserList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserUserList.h"
#import "WTCallback.h"

@interface WeiboUserUserList ()
{
    struct {
        unsigned int isLoading: 1;
        unsigned int isAtEnd: 1;
    } _flags;
}

@property (nonatomic, retain) NSMutableArray * users;
@property (nonatomic, retain) NSString * cursor;

@end

@implementation WeiboUserUserList
@synthesize users = _users;

- (void)dealloc
{
    [_users release], _users = nil;
    [_cursor release], _cursor = nil;
    [_user release], _user = nil;
    [_account release], _account = nil;
    [super dealloc];
}

- (void)_loadOlder
{
    
}
- (void)loadOlder
{
    if (!_flags.isLoading)
    {
        [self _loadOlder];
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
    }
}

- (void)markAtEnd
{
    _flags.isAtEnd = YES;
}

- (void)didAddUsers:(NSArray *)users
{
    
}
- (NSArray *)users
{
    return _users;
}

- (WTCallback *)receiveUsersCallback
{
    return WTCallbackMake(self, @selector(_usersResponse:info:), nil);
}

- (void)_usersResponse:(id)response info:(id)info
{
    
}


@end
