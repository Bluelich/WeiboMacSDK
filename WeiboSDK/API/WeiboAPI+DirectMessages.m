//
//  WeiboAPI+DirectMessages.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+DirectMessages.h"
#import "WeiboAPI+Private.h"
#import "JSONKit.h"
#import "WeiboDirectMessage.h"
#import "WeiboDirectMessageConversation.h"

@implementation WeiboAPI (DirectMessages)

#pragma mark -
#pragma mark Direct Message
- (WeiboCallback *)directMessageResponseCallback
{
    return WeiboCallbackMake(self, @selector(directMessageResponse:info:), nil);
}
- (WeiboCallback *)directMessagesResponseCallback
{
    return WeiboCallbackMake(self, @selector(directMessagesResponse:info:), nil);
}
- (void)directMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count
{
    WeiboCallback * callback = [self directMessagesResponseCallback];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (since) [params setObject:@(since) forKey:@"since_id"];
    if (max) [params setObject:@(max) forKey:@"max_id"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"direct_messages.json" parameters:params callback:callback];
}
- (void)sentDirectMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count
{
    WeiboCallback * callback = [self directMessagesResponseCallback];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (since) [params setObject:@(since) forKey:@"since_id"];
    if (max) [params setObject:@(max) forKey:@"max_id"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"direct_messages/sent.json" parameters:params callback:callback];
}
- (void)publicMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count
{
    WeiboCallback * callback = [self directMessagesResponseCallback];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (since) [params setObject:@(since) forKey:@"since_id"];
    if (max) [params setObject:@(max) forKey:@"max_id"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"direct_messages/public/messages.json" parameters:params callback:callback];
}

- (void)directMessageResponse:(id __attribute__((unused)))response info:(id __attribute__((unused)))info
{
    WeiboUnimplementedMethod;
}
- (void)directMessagesResponse:(id)response info:(id __attribute__((unused)))info
{
    [WeiboDirectMessage parseObjectsWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}

- (void)conversationsWithCount:(NSInteger)count cursor:(WeiboUserID)cursor
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(directMessageConversationResponse:info:), nil);
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (count) [params setObject:@(count) forKey:@"count"];
    if (cursor) [params setObject:@(cursor) forKey:@"cursor"];
    
    [self GET:@"direct_messages/user_list.json" parameters:params callback:callback];
}

- (void)directMessageConversationResponse:(id)returnValue info:(id __attribute__((unused)))info
{
    [WeiboDirectMessageConversation parseObjectsWithJSONObject:returnValue account:authenticateWithAccount callback:responseCallback];
}

- (void)directMessagesWithUserID:(WeiboUserID)userID since:(WeiboMessageID)since max:(WeiboMessageID)max count:(NSUInteger)count
{
    WeiboCallback * callback = [self directMessagesResponseCallback];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (userID) [params setObject:@(userID) forKey:@"uid"];
    if (since) [params setObject:@(since) forKey:@"since_id"];
    if (max) [params setObject:@(max) forKey:@"max_id"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"direct_messages/conversation.json" parameters:params callback:callback];
}

- (void)sendDirectMessage:(NSString *)text toUserID:(WeiboUserID)userID
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(directMessageSendResponse:info:), nil);
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (text) [params setObject:text forKey:@"text"];
    if (userID) [params setObject:@(userID) forKey:@"uid"];
    
    [self POST:@"direct_messages/new.json" parameters:params callback:callback];
}

- (void)directMessageSendResponse:(id)response info:(id __attribute__((unused)))info
{
    [responseCallback invoke:response];
    
    dispatch_next(^{
        [self->authenticateWithAccount refreshTimelineForType:WeiboCompositionTypeDirectMessage];
    });
}

@end
