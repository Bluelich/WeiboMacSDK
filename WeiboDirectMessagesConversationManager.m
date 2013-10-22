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
#import "NSArray+WeiboAdditions.h"

NSString * const WeiboDirectMessagesConversationListDidUpdateNotification = @"WeiboDirectMessagesConversationListDidUpdateNotification";
NSString * const WeiboDirectMessagesManagerDidFinishLoadingNotification = @"WeiboDirectMessagesManagerDidFinishLoadingNotification";

@interface WeiboDirectMessagesConversationManager ()
{
    WeiboSentDirectMessageStream * _sentStream;
    WeiboReceivedDirectMessageStream * _receivedStream;
    NSMutableArray * _conversations;
    NSInteger streamingRequestCount;
    struct {
        unsigned int conversationsLoaded : 1;
        unsigned int streaming : 1;
    } _flags;
}

@property (nonatomic, retain) WeiboSentDirectMessageStream * sentStream;
@property (nonatomic, retain) WeiboReceivedDirectMessageStream * receivedStream;

@property (nonatomic, retain) NSArray * unreadConversationUserIDsFromCache;

@property (nonatomic, retain) NSTimer * pollTimer;

@end

@implementation WeiboDirectMessagesConversationManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self _stopStreaming];
    [_sentStream release], _sentStream = nil;
    [_receivedStream release], _receivedStream = nil;
    [_conversations release], _conversations = nil;
    
    [_unreadConversationUserIDsFromCache release], _unreadConversationUserIDsFromCache = nil;
    
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
        _unreadConversationUserIDsFromCache = [[aDecoder decodeObjectForKey:@"unread-state"] retain];
        
        [self _setupNotifications];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray * unreadConversations = self.unreadConversations;
    NSMutableArray * userIDs = [NSMutableArray array];
    
    for (WeiboDirectMessageConversation * conversation in unreadConversations)
    {
        [userIDs addObject:@(conversation.correspondent.userID)];
    }
    
    [aCoder encodeObject:userIDs forKey:@"unread-state"];
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

- (void)initialzeConversationsIfNeeded
{
    if (!_flags.conversationsLoaded)
    {
        [self refresh];
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesStreamFinishedLoading:) name:WeiboDirectMessageStreamFinishedLoadingNotification object:nil];
}

- (WeiboDirectMessageConversation *)conversationWithUserID:(WeiboUserID)userID
{
    for (WeiboDirectMessageConversation * conversation in _conversations)
    {
        if (conversation.correspondent.userID == userID)
        {
            return conversation;
        }
    }
    return nil;
}

- (WeiboDirectMessageConversation *)conversationWith:(WeiboUser *)user
{
    return [self conversationWithUserID:user.userID];
}

- (void)_addStubConversation:(WeiboDirectMessageConversation *)conversation
{
    if (!conversation) return;
    
    [_conversations addObject:conversation];
}

- (void)addMessages:(NSArray *)messages fromMe:(BOOL)fromMe
{
    if (messages.count)
    {
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
            
            if (!_flags.conversationsLoaded)
            {
                message.read = YES; // first load
            }
        }
        
        [_conversations makeObjectsPerformSelector:@selector(endAddingMessages)];
        
        [_conversations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessagesConversationListDidUpdateNotification object:self];
    }
}

- (void)messagesStreamFinishedLoading:(NSNotification *)notification
{
    if (notification.object != _sentStream && notification.object != _receivedStream)
    {
        return;
    }
    
    if (_sentStream.messagesLoaded && _receivedStream.messagesLoaded)
    {
        if (!_flags.conversationsLoaded)
        {
            // restore unread state
            
            if (self.unreadConversationUserIDsFromCache.count)
            {
                WeiboUser * me = _sentStream.account.user;
                
                for (NSNumber * userID in self.unreadConversationUserIDsFromCache)
                {
                    WeiboDirectMessageConversation * conversation = [self conversationWithUserID:userID.longLongValue];
                    if (!conversation) continue;
                    
                    WeiboDirectMessage * message = [conversation newestMessageNotFrom:me];
                    
                    message.read = NO;
                }
                
                self.unreadConversationUserIDsFromCache = nil;
            }
            
            _flags.conversationsLoaded = YES;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessagesManagerDidFinishLoadingNotification object:self];
    }
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

- (BOOL)isLoadingNewer
{
    return _sentStream.isLoadingNewer || _receivedStream.isLoadingNewer;
}
- (BOOL)isLoadingOlder
{
    return _sentStream.isLoadingOlder || _receivedStream.isLoadingOlder;
}
- (BOOL)isLoading
{
    return self.isLoadingNewer || self.isLoadingOlder;
}

#pragma mark - Streaming

- (void)_startStreaming
{
    if (!_flags.streaming)
    {
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                          target:self
                                                        selector:@selector(refresh)
                                                        userInfo:nil
                                                         repeats:YES];
        [self.pollTimer fire];

        
        _flags.streaming = YES;
    }
}
- (void)_stopStreaming
{
    if (_flags.streaming)
    {
        [self.pollTimer invalidate];
        [self setPollTimer:nil];
        
        _flags.streaming = NO;
    }
}

- (void)requestStreaming
{
    streamingRequestCount++;
    
    [self _startStreaming];
}
- (void)endStreaming
{
    streamingRequestCount--;
    
    if (streamingRequestCount <= 0)
    {
        [self _stopStreaming];
        
        streamingRequestCount = 0;
    }
}

@end
