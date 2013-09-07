//
//  WeiboDirectMessageConversation.m
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessageConversation.h"

@interface WeiboDirectMessageConversation ()
{
    NSMutableArray * _messages;
}

@end

@implementation WeiboDirectMessageConversation

- (void)dealloc
{
    [_correspondent release], _correspondent = nil;
    [_messages release], _messages = nil;
    [super dealloc];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        self.correspondent = [aDecoder decodeObjectForKey:@"correspondent"];
        
        NSArray * messages = [aDecoder decodeObjectForKey:@"messages"];
        
        [self beginAddingMessages];
        for (WeiboDirectMessage * message in messages)
        {
            [self addMessage:message];
        }
        [self endAddingMessages];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.correspondent forKey:@"correspondent"];
    [aCoder encodeObject:self.messages forKey:@"messages"];
}

- (NSArray *)messages
{
    return _messages;
}

- (WeiboDirectMessage *)newestMessageNotFrom:(WeiboUser *)user
{
    for (WeiboDirectMessage * message in _messages)
    {
        if (message.senderID != user.userID) return message;
    }
    return nil;
}
- (void)beginAddingMessages
{
    
}
- (void)addMessage:(WeiboDirectMessage *)message
{
    if (!message) return;
    
    // TODO: sort
    
    [_messages addObject:message];
}
- (void)endAddingMessages
{
    
}

- (void)deleteMessage:(WeiboDirectMessage *)message
{
    [_messages removeObject:message];
}
- (BOOL)isRepliedTo
{
    return self.mostRecentMessage.senderID != self.correspondent.userID;
}
- (BOOL)hasUnreadMessages
{
    for (WeiboDirectMessage * message in _messages)
    {
        if (!message.read) return YES;
    }
    return NO;
}
- (void)markAsRead
{
    for (WeiboDirectMessage * message in _messages)
    {
        message.read = YES;
    }
}

@end
