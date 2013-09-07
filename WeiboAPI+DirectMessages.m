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

@implementation WeiboAPI (DirectMessages)

#pragma mark -
#pragma mark Direct Message
- (WTCallback *)directMessageResponseCallback
{
    return WTCallbackMake(self, @selector(directMessageResponse:info:), nil);
}
- (WTCallback *)directMessagesResponseCallback
{
    return WTCallbackMake(self, @selector(directMessagesResponse:info:), nil);
}
- (void)directMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count
{
    WTCallback * callback = [self directMessagesResponseCallback];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    if (since) [params setObject:@(since) forKey:@"since_id"];
    if (max) [params setObject:@(max) forKey:@"max_id"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"direct_messages.json" parameters:params callback:callback];
}
- (void)sentDirectMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count
{
    WTCallback * callback = [self directMessagesResponseCallback];
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * dict = [(NSString *)response objectFromJSONString];
        NSArray * messageDicts = [dict objectForKey:@"direct_messages"];
        NSMutableArray * messages = [NSMutableArray arrayWithCapacity:messageDicts.count];
        
        for (NSDictionary * messageDict in messageDicts)
        {
            WeiboDirectMessage * message = [[WeiboDirectMessage alloc] initWithDictionary:messageDict];
            [messages addObject:message];
            [message release];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [responseCallback invoke:messages];
        });
    });
}

@end
