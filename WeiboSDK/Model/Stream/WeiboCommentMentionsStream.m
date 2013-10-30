//
//  WeiboCommentMentionsStream.m
//  Weibo
//
//  Created by Wutian on 13-10-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboCommentMentionsStream.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboUserNotificationCenter.h"

@implementation WeiboCommentMentionsStream

- (BOOL)shouldIndexUsersInAutocomplete
{
    return YES;
}
- (void)_loadNewer
{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentMentionsSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentMentionsSinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSUInteger)minStatusesToConsiderBeingGap
{
    return NSUIntegerMax;
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"comment_mentions.scrollPosition"];
}

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type
{
    [super noticeDidReceiveNewStatuses:newStatuses withAddingType:type];
    
    if (type == WeiboStatusesAddingTypePrepend)
    {
        [[WeiboUserNotificationCenter defaultUserNotificationCenter] scheduleNotificationForMentions:newStatuses forAccount:self.account];
    }
}

@end
