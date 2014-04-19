//
//  WeiboMentionsStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-22.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboMentionsStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboUserNotificationCenter.h"

@implementation WeiboMentionsStream

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        if (self.account)
        {
            // return the shared stream
            typeof(self) __strong stream = self.account.statusMentionsStream;
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
    [api mentionsSinceID:[self newestStatusID] maxID:0 page:1 count:100];
}
- (void)_loadOlder{
    WeiboCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api mentionsSinceID:0 maxID:0 page:self.loadOlderSuccessTimes + 2 count:100];
}
- (NSUInteger)maxCount
{
    return 3000;
}
- (NSUInteger)minStatusesToConsiderBeingGap{
    return NSUIntegerMax;
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"mentions.scrollPosition"];
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
