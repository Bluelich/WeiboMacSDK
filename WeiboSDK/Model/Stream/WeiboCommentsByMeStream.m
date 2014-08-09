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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        if (self.account)
        {
            // return the shared stream
            typeof(self) __strong stream = self.account.commentsByMeStream;
            self = nil;
            return stream;
        }
    }
    return self;
}

- (BOOL)shouldIndexUsersInAutocomplete
{
    return YES;
}
- (void)_loadNewer
{
    WeiboCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsByMeSinceID:[self newestStatusID] maxID:0 page:1 count:100];
}
- (void)_loadOlder
{
    WeiboCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentsByMeSinceID:0 maxID:0 page:self.loadOlderSuccessTimes + 2 count:100];
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
    return [[super autosaveName] stringByAppendingString:@"comments_by_me.scrollPosition"];
}

- (NSUInteger)unreadCount
{
    return 0; // We must readed all comments sent by ourselves
}

@end
