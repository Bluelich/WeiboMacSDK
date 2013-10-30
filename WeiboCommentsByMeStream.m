//
//  WeiboCommentsByMeStream.m
//  Weibo
//
//  Created by Wutian on 13-10-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboCommentsByMeStream.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboCommentsByMeStream

- (BOOL)shouldIndexUsersInAutocomplete
{
    return YES;
}
- (void)_loadNewer
{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsByMeSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder
{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsByMeSinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSUInteger)minStatusesToConsiderBeingGap
{
    return NSUIntegerMax;
}
- (NSString *)autosaveName
{
    return [[super autosaveName] stringByAppendingString:@"comments_by_me.scrollPosition"];
}

- (NSInteger)unreadCount
{
    return 0; // We must readed all comments sent by ourselves
}

@end
