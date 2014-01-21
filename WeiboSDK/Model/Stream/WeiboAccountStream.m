//
//  WeiboAccountStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"
#import "WeiboAccount.h"
#import "WeiboAccount+Filters.h"
#import "WeiboBaseStatus.h"
#import "WeiboUser.h"

@implementation WeiboAccountStream
@synthesize account;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [account release], account = nil;
    [super dealloc];
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRemarkDidUpdateNotification:) name:WeiboUserRemarkDidUpdateNotification object:nil];
    }
    return self;
}

- (WeiboBaseStatus *)newestStatusThatIsNotMine{
    for (WeiboBaseStatus * status in self.statuses)
    {
        if (status.user.userID != self.account.user.userID)
        {
            return status;
        }
    }
    return nil;
}
- (NSString *)autosaveName{
    return [[super autosaveName] 
            stringByAppendingFormat:@"weibo.com/%lld/",account.user.userID];
}

- (NSArray *)statusFilters
{
    return account.allFilters;
}

- (void)userRemarkDidUpdateNotification:(NSNotification *)notification
{
    if (notification.object == self.account)
    {
        WeiboUserID userID = [notification.userInfo[@"userID"] longLongValue];
        NSString * remark = notification.userInfo[@"remark"];
        
        for (WeiboBaseStatus * status in self.statuses)
        {
            if (status.user.userID == userID)
            {
                status.user.remark = remark;
            }
        }
    }
}

@end
