//
//  WeiboCommentsTimelineStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-22.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboCommentsTimelineStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboUserNotificationCenter.h"

@implementation WeiboCommentsTimelineStream

- (BOOL)shouldIndexUsersInAutocomplete{
    return YES;
}
- (void)_loadNewer{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsTimelineSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsTimelineSinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSUInteger)minStatusesToConsiderBeingGap{
    return NSUIntegerMax;
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"comment.scrollPosition"];
}

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type
{
    [super noticeDidReceiveNewStatuses:newStatuses withAddingType:type];
    
    if (type == WeiboStatusesAddingTypePrepend)
    {
        [[WeiboUserNotificationCenter defaultUserNotificationCenter] scheduleNotificationForComments:newStatuses forAccount:self.account];
    }
}

@end
