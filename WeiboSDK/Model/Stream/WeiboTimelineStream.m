//
//  WeiboTimelineStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboTimelineStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI.h"

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
    [api friendsTimelineSinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"timeline.scrollPosition"];
}
@end
