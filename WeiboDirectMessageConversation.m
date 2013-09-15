//
//  WeiboDirectMessageConversation.m
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessageConversation.h"

NSString * const WeiboDirectMessageConversationDidUpdateNotification = @"WeiboDirectMessageConversationDidUpdateNotification";
NSString * const WeiboDirectMessageConversationDidMarkAsReadNotification = @"WeiboDirectMessageConversationDidMarkAsReadNotification";

@interface WeiboDirectMessageConversation ()
{
    NSMutableArray * _messages;
    
    struct {
        unsigned int didAddMessage:1;
    } _flags;
}

@end

@implementation WeiboDirectMessageConversation

- (void)dealloc
{
    [_correspondent release], _correspondent = nil;
    [_messages release], _messages = nil;
    [super dealloc];
}

+ (instancetype)conversationWithDictionary:(NSDictionary *)dict
{
    WeiboDirectMessageConversation * conversation = [[self alloc] init];
    
    conversation.correspondent = [WeiboUser userWithDictionary:[dict objectForKey:@"user"]];
    
    WeiboDirectMessage * message = [[WeiboDirectMessage alloc] initWithDictionary:[dict objectForKey:@"direct_message"]];
    
    [conversation addMessage:[message autorelease]];
    
    return [conversation autorelease];
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
    _flags.didAddMessage = NO;
}
- (void)addMessage:(WeiboDirectMessage *)message
{
    if (!message) return;
    
    NSInteger idx = [_messages indexOfObject:message inSortedRange:NSMakeRange(0, _messages.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(WeiboDirectMessage * obj1, WeiboDirectMessage * obj2) {
        return [obj1 compare:obj2];
    }];
    
    [_messages insertObject:message atIndex:idx];
    
    _flags.didAddMessage = YES;
}
- (void)endAddingMessages
{
    if (_flags.didAddMessage)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessageConversationDidUpdateNotification object:self];
    }
    _flags.didAddMessage = NO;
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
    for (WeiboDirectMessage * message in [_messages reverseObjectEnumerator])
    {
        if (message.senderID == self.correspondent.userID)
        {
            return !message.read;
        }
    }
    return NO;
}
- (void)markAsRead
{
    BOOL postsNotification = self.hasUnreadMessages;
    
    for (WeiboDirectMessage * message in _messages)
    {
        message.read = YES;
    }
    
    if (postsNotification)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessageConversationDidMarkAsReadNotification object:self];
    }
}
- (WeiboDirectMessage *)mostRecentMessage
{
    return [self.messages lastObject];
}

- (NSComparisonResult)compare:(WeiboDirectMessageConversation *)other
{
    time_t mostRecentDate = self.mostRecentMessage.date;
    time_t otherMostRecentDate = other.mostRecentMessage.date;
    
    if (mostRecentDate > otherMostRecentDate)
    {
        return NSOrderedAscending;
    }
    else if (mostRecentDate < otherMostRecentDate)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedSame;
    }
}

@end
