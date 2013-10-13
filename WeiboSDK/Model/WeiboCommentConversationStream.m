//
//  WeiboCommentConversationStream.m
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboCommentConversationStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboComment.h"
#import "WTFoundationUtilities.h"

@implementation WeiboCommentConversationStream

- (void)dealloc
{
    [_sourceComment release], _sourceComment = nil;
    [super dealloc];
}

- (WeiboComment *)oldestReplyingComment
{
    WeiboComment * sourceComment = [self.statuses lastObject];
    if (!sourceComment) sourceComment = self.sourceComment;
    
    return sourceComment.replyToComment;
}

- (void)_loadNewer
{
    
}
- (void)_loadOlder
{
    WeiboComment * replyingComment = [self oldestReplyingComment];
    
    WeiboStatusID commentID = replyingComment.sid;
    
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api commentWithID:commentID];
}
- (void)loadOlder
{
    WeiboComment * replyingComment = [self oldestReplyingComment];
    
    if (!replyingComment) return;

    [super loadOlder];
}
- (BOOL)supportsFillingInGaps
{
    return NO;
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type
{
    for (WeiboComment * comment in newStatuses)
    {
        if ([comment isKindOfClass:[WeiboComment class]])
        {
            [comment setTreatReplyingStatusAsQuoted:NO];
            [comment setTreatReplyingCommentAsQuoted:NO];
        }
    }
    [super addStatuses:newStatuses withType:type];
}

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type
{
    if (![self oldestReplyingComment])
    {
        [self  markAtEnd];
    }
    
    [super noticeDidReceiveNewStatuses:newStatuses withAddingType:type];
}

@end
