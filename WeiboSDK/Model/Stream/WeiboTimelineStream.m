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
#import "WeiboUserNotificationCenter.h"

@implementation WeiboTimelineStream

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        if (self.account)
        {
            // return the shared stream
            typeof(self) __strong stream = self.account.timelineStream;
            self = nil;
            return stream;
        }
    }
    return self;
}

- (BOOL)shouldIndexUsersInAutocomplete{
    return YES;
}
- (void)_loadNewer{
    WeiboCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api friendsTimelineSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WeiboCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    
    WeiboStatusID oldestID = self.oldestStatusID;
    WeiboStatusID maxID = oldestID > 0 ? (oldestID - 1) : 0;
    [api friendsTimelineSinceID:0 maxID:maxID count:100];
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"timeline.scrollPosition"];
}

- (BOOL)appliesStatusFilter
{
    return YES;
}

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type
{
    [super noticeDidReceiveNewStatuses:newStatuses withAddingType:type];
    
    if (type == WeiboStatusesAddingTypePrepend)
    {
        [[WeiboUserNotificationCenter defaultUserNotificationCenter] scheduleNotificationForStatuses:newStatuses forAccount:self.account];
    }
}

@end
