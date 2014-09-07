//
//  WeiboUserFollowersList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserFollowersList.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboAccount+Superpower.h"

@implementation WeiboUserFollowersList

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self usersListCallbackWithLoadingNewer:YES]];
    [api followersForUserID:self.user.userID cursor:0];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self usersListCallbackWithLoadingNewer:NO]];
    [api followersForUserID:self.user.userID cursor:self.cursor];
}

- (void)didAddUsers:(NSArray *)users prepend:(BOOL)prepend
{
    [super didAddUsers:users prepend:prepend];
    
    if (users.count == self.users.count ||
        prepend)
    {
        // Loading Newer
        
        if ([self.user isEqual:self.account.user] ||
            [self.account hasNewFollowers])
        {
            [self.account resetUnreadCountWithType:WeiboUnreadCountTypeFollower];
        }
    }
}

@end
