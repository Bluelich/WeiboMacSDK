//
//  WeiboDirectMessagesConversationManager.m
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessagesConversationManager.h"

@interface WeiboDirectMessagesConversationManager ()
{
    WeiboSentDirectMessageStream * _sentStream;
    WeiboReceivedDirectMessageStream * _receivedStream;
    NSMutableArray * _conversations;
}

@end

@implementation WeiboDirectMessagesConversationManager

- (void)dealloc
{
    [_sentStream release], _sentStream = nil;
    [_receivedStream release], _receivedStream = nil;
    [_conversations release], _conversations = nil;
    [super dealloc];
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (instancetype)initWithAccount:(WeiboAccount *)account
{
    if (self = [self init])
    {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
