//
//  WeiboCommentsToMeStream.m
//  Weibo
//
//  Created by Wutian on 13-10-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboCommentsToMeStream.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboUserNotificationCenter.h"

@implementation WeiboCommentsToMeStream

- (BOOL)shouldIndexUsersInAutocomplete
{
    return YES;
}
- (void)_loadNewer
{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsToMeSinceID:[self newestStatusID] maxID:0 page:1 count:100];
}
- (void)_loadOlder
{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsToMeSinceID:0 maxID:0 page:self.loadOlderSuccessTimes + 2 count:100];
}
- (NSUInteger)maxCount
{
    return 3000;
}
- (NSUInteger)minStatusesToConsiderBeingGap
{
    return NSUIntegerMax;
}
- (NSString *)autosaveName
{
    return [[super autosaveName] stringByAppendingString:@"comments_to_me.scrollPosition"];
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
