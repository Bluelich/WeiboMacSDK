//
//  WeiboUserTimelineStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUserTimelineStream.h"
#import "WeiboAPI.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"

@implementation WeiboUserTimelineStream

- (void)_loadNewer{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api userTimelineForUsername:self.user.screenName sinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api userTimelineForUsername:self.user.screenName sinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"timeline.scrollPosition"];
}

@end
