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
#import "WeiboDirectMessagesConversationManager_Private.h"

NSString * const WeiboDirectMessagesConversationListDidUpdateNotification = @"WeiboDirectMessagesConversationListDidUpdateNotification";
NSString * const WeiboDirectMessagesManagerDidFinishLoadingNotification = @"WeiboDirectMessagesManagerDidFinishLoadingNotification";

@interface WeiboDirectMessagesConversationManager ()
{
    NSMutableArray * _conversations;
    NSInteger streamingRequestCount;
    struct {
        unsigned int conversationsLoaded : 1;
        unsigned int streaming : 1;
    } _flags;
}

@property (nonatomic, strong) NSArray * unreadConversationUserIDsFromCache;

@property (nonatomic, strong) NSTimer * pollTimer;

@end

@implementation WeiboDirectMessagesConversationManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self _stopStreaming];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _conversations = [[NSMutableArray alloc] init];
        
        [self _setupNotifications];
    }
    return self;
}

- (instancetype)initWithAccount:(WeiboAccount *)account
{
    if (self = [self init])
    {
        self.account = account;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {        
        _unreadConversationUserIDsFromCache = [aDecoder decodeObjectForKey:@"unread-state"];
        
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

- (void)initialzeConversationsIfNeeded
{
    if (!_flags.conversationsLoaded)
    {
        [self refresh];
    }
}

- (void)refresh
{
    [self.messageStreams makeObjectsPerformSelector:@selector(loadNewer)];
}
- (void)loadOlder
{
    [self.messageStreams makeObjectsPerformSelector:@selector(loadOlder)];
}

- (void)_setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStreamDidUpdate:) name:WeiboDirectMessageStreamDidUpdateNotification object:nil];
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
            }
            
            [conversation addMessage:message];
            
            // optimizing memory usage, point user to a shared object, hope this works
            WeiboUser * me = self.account.user;
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
    NSArray * messageStreams = self.messageStreams;
    
    if (![messageStreams containsObject:notification.object]) {
        return;
    }
    
    BOOL everyStreamLoaded = YES;
    
    for (WeiboDirectMessageStream * stream in messageStreams) {
        if (!stream.messagesLoaded) {
            everyStreamLoaded = NO;
            break;
        }
    }
    
    if (everyStreamLoaded)
    {
        if (!_flags.conversationsLoaded)
        {
            // restore unread state
            
            if (self.unreadConversationUserIDsFromCache.count)
            {
                WeiboUser * me = self.account.user;
                
                for (NSNumber * userID in self.unreadConversationUserIDsFromCache)
                {
                    WeiboDirectMessageConversation * conversation = [self conversationWithUserID:userID.unsignedLongLongValue];
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

- (void)messageStreamDidUpdate:(NSNotification *)notification
{
    WeiboDirectMessageStream * stream = notification.object;
    
    if (![self.messageStreams containsObject:stream]) return;
    
    NSArray * messages = notification.userInfo[@"messages"];
    
    [self addMessages:messages fromMe:stream.messagesFromAccount];
}

- (time_t)newestMessageDate
{
    return [[self newestMessageOnlyFromOthers:NO] date];
}

- (WeiboDirectMessage *)newestMessageNotFromMe
{
    return [self newestMessageOnlyFromOthers:YES];
}

- (WeiboDirectMessage *)newestMessageOnlyFromOthers:(BOOL)onlyFromOthers
{
    WeiboDirectMessage * newest = nil;
    
    for (WeiboDirectMessageStream * stream in self.messageStreams) {
        if (onlyFromOthers && stream.messagesFromAccount) continue;
        WeiboDirectMessage * message = stream.messages.lastObject;
        if (message.date > newest.date) {
            newest = message;
        }
    }
    
    return newest;
}

- (time_t)newestMessageDateNotFromMe
{
    return [[self newestMessageNotFromMe] date];
}

- (void)_deleteMessage:(WeiboDirectMessage * __attribute__((unused)))message
{
    
}

- (void)deleteMessage:(WeiboDirectMessage * __attribute__((unused)))message
{
    
}

- (void)didDeleteMessage:(id __attribute__((unused)))response info:(id __attribute__((unused)))info
{
    
}

- (void)deleteConversation:(WeiboDirectMessageConversation *)conversation
{
    [_conversations removeObject:conversation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessagesConversationListDidUpdateNotification object:self];
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

- (void)markConversationWithUserIDAsRead:(WeiboUserID)userID
{
    [[self conversationWithUserID:userID] markAsRead];
}

- (void)clearCachedUnreadState
{
    
}

- (BOOL)isLoadingNewer
{
    for (WeiboDirectMessageStream * stream in self.messageStreams) {
        if (stream.isLoadingNewer) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)isLoadingOlder
{
    for (WeiboDirectMessageStream * stream in self.messageStreams) {
        if (stream.isLoadingOlder) {
            return YES;
        }
    }
    return NO;
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
