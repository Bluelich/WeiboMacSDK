//
//  WeiboUserFollowingList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserFollowingList.h"
#import "WeiboAPI+UserMethods.h"

@implementation WeiboUserFollowingList

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedRequest:[self usersListCallbackWithCursor:0]];
    [api friendsForUserID:self.user.userID cursor:0];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedRequest:[self usersListCallbackWithCursor:self.cursor]];
    [api friendsForUserID:self.user.userID cursor:self.cursor];
}

@end
