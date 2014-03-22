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
- (void)directMessageResponse:(id)response info:(id)info
{
    WeiboUnimplementedMethod;
}
- (void)directMessagesResponse:(id)response info:(id)info
{
    [WeiboDirectMessage parseObjectsWithJSONObject:response callback:responseCallback];
}

- (void)conversationsWithCount:(NSInteger)count cursor:(WeiboUserID)cursor
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(directMessageConversationResponse:info:), nil);
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (count) [params setObject:@(count) forKey:@"count"];
    if (cursor) [params setObject:@(cursor) forKey:@"cursor"];
    
    [self GET:@"direct_messages/user_list.json" parameters:params callback:callback];
}

- (void)directMessageConversationResponse:(id)returnValue info:(id)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * conversationDicts = [returnValue objectForKey:@"user_list"];
        
        NSMutableArray * conversations = [NSMutableArray array];
        
        for (NSDictionary * conversationDict in conversationDicts)
        {
            [conversations addObject:[WeiboDirectMessageConversation conversationWithDictionary:conversationDict]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [responseCallback invoke:conversations];
        });
    });
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

- (void)directMessageSendResponse:(id)response info:(id)info
{
    [authenticateWithAccount refreshTimelineForType:WeiboCompositionTypeDirectMessage];
    [responseCallback invoke:response];
}

@end
