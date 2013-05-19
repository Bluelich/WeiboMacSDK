//
//  WeiboUserFollowersList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserFollowersList.h"
#import "WeiboAPI+UserMethods.h"

@implementation WeiboUserFollowersList

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedRequest:[self usersListCallbackWithCursor:0]];
    [api followersForUserID:self.user.userID cursor:0];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedRequest:[self usersListCallbackWithCursor:self.cursor]];
    [api followersForUserID:self.user.userID cursor:self.cursor];
}

@end
