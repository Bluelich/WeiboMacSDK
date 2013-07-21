//
//  WeiboTimelineStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboTimelineStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboTimelineStream

- (BOOL)shouldIndexUsersInAutocomplete{
    return YES;
}
- (void)_loadNewer{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api friendsTimelineSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    
    WeiboStatusID oldestID = self.oldestStatusID;
    WeiboStatusID maxID = oldestID > 0 ? (oldestID - 1) : 0;
    [api friendsTimelineSinceID:0 maxID:maxID count:100];
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"timeline.scrollPosition"];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type
{
    NSMutableArray * result = [NSMutableArray arrayWithArray:newStatuses];
    WeiboAccount * account = self.account;

    // TODO:    remove blocked username, keyword, client with account
    //          highlight status that mentioned account, or marked by account settings.
    
    [super addStatuses:result withType:type];
}

@end
