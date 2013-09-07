//
//  WeiboDirectMessagesConversationManager.m
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessagesConversationManager.h"
#import "WeiboDirectMessage.h"
#import "WeiboDirectMessageConversation.h"
#import "WeiboAccount.h"

NSString * const WeiboDirectMessagesConversationListDidUpdateNotification = @"WeiboDirectMessagesConversationListDidUpdateNotification";

@interface WeiboDirectMessagesConversationManager ()
{
    WeiboSentDirectMessageStream * _sentStream;
    WeiboReceivedDirectMessageStream * _receivedStream;
    NSMutableArray * _conversations;
}

@property (nonatomic, retain) WeiboSentDirectMessageStream * sentStream;
@property (nonatomic, retain) WeiboReceivedDirectMessageStream * receivedStream;

@end

@implementation WeiboDirectMessagesConversationManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_sentStream release], _sentStream = nil;
    [_receivedStream release], _receivedStream = nil;
    [_conversations release], _conversations = nil;
    [super dealloc];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _conversations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithAccount:(WeiboAccount *)account
{
    if (self = [self init])
    {
        [self setAccount:account];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        _sentStream = [[aDecoder decodeObjectForKey:@"sent-stream"] retain];
        _receivedStream = [[aDecoder decodeObjectForKey:@"received-stream"] retain];
        _conversations = [[aDecoder decodeObjectForKey:@"conversations"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sentStream forKey:@"sent-stream"];
    [aCoder encodeObject:_receivedStream forKey:@"received-stream"];
    [aCoder encodeObject:_conversations forKey:@"conversations"];
}

- (void)setAccount:(WeiboAccount *)account
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.sentStream = [[[WeiboSentDirectMessageStream alloc] init] autorelease];
    self.receivedStream = [[[WeiboReceivedDirectMessageStream alloc] init] autorelease];
    
    self.sentStream.account = account;
    self.receivedStream.account = account;
    
    [self _setupNotifications];
}

- (void)refresh
{
    [_receivedStream loadNewer];
    [_sentStream loadNewer];
}
- (void)loadOlder
{
    [_receivedStream loadOlder];
    [_sentStream loadOlder];
}

- (void)_setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentDidUpdate:) name:WeiboDirectMessageStreamDidUpdateNotification object:_sentStream];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDidUpdate:) name:WeiboDirectMessageStreamDidUpdateNotification object:_receivedStream];
}

- (WeiboDirectMessageConversation *)conversationWith:(WeiboUser *)user
{
    for (WeiboDirectMessageConversation * conversation in self.conversations)
    {
        if (conversation.correspondent.userID == user.userID) return conversation;
    }
    return nil;
}

- (void)_addStubConversation:(WeiboDirectMessageConversation *)conversation
{
    if (!conversation) return;
    
    [_conversations insertObject:conversation atIndex:0];
}

- (void)addMessages:(NSArray *)messages fromMe:(BOOL)fromMe
{
    if (!messages.count) return;
    
    [_conversations makeObjectsPerformSelector:@selector(beginAddingMessages)];
    
    for (WeiboDirectMessage * message in messages)
    {
        WeiboUser * correspondent = fromMe ? message.recipient : message.sender;
        WeiboDirectMessageConversation * conversation = [self conversationWith:correspondent];
        if (!conversation)
        {
            conversation = [[WeiboDirectMessageConversation alloc] init];
            conversation.correspondent = correspondent;
            [self _addStubConversation:conversation];
            [conversation beginAddingMessages];
            [conversation release];
        }
        
        [conversation addMessage:message];
        
        // optimizing memory usage, point user to a shared object, hope this works
        WeiboUser * me = _sentStream.account.user;
        WeiboUser * he = conversation.correspondent;
        
        message.sender = fromMe ? me : he;
        message.recipient = fromMe ? he : me;
    }
    
    [_conversations makeObjectsPerformSelector:@selector(endAddingMessages)];
    
    [_conversations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessagesConversationListDidUpdateNotification object:self];
}

- (void)sentDidUpdate:(NSNotification *)notification
{
    NSArray * messages = notification.userInfo[@"messages"];
    
    [self addMessages:messages fromMe:YES];
}

- (void)receivedDidUpdate:(NSNotification *)notification
{
    NSArray * messages = notification.userInfo[@"messages"];
    
    [self addMessages:messages fromMe:NO];
}

- (time_t)newestMessageDate
{
    time_t newestSentDate = [(WeiboDirectMessage *)self.sentStream.messages.lastObject date];
    
    return MAX([self newestMessageDateNotFromMe], newestSentDate);
}

- (WeiboDirectMessage *)newestMessageNotFromMe
{
    return _receivedStream.messages.lastObject;
}

- (time_t)newestMessageDateNotFromMe
{
    return [[self newestMessageNotFromMe] date];
}

- (void)_deleteMessage:(WeiboDirectMessage *)message
{
    
}

- (void)deleteMessage:(WeiboDirectMessage *)message
{
    
}

- (void)didDeleteMessage:(id)response info:(id)info
{
    
}

- (void)deleteConversation:(WeiboDirectMessageConversation *)conversation
{
    
}

- (NSArray *)unreadConversations
{
    NSMutableArray * conversations = [NSMutableArray array];
    
    for (WeiboDirectMessageConversation * c in _conversations)
    {
        if (c.hasUnreadMessages) [conversations addObject:c];
    }
    
    return conversations;
}

- (BOOL)hasUnreadMessage
{
    return ![[self newestMessageNotFromMe] read];
}

- (void)markAllAsRead
{
    [self.conversations makeObjectsPerformSelector:@selector(markAsRead)];
}

- (void)clearCachedUnreadState
{
    
}

@end
