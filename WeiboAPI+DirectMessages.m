//
//  WeiboAPI+DirectMessages.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+DirectMessages.h"

@implementation WeiboAPI (DirectMessages)

#pragma mark -
#pragma mark Direct Message
- (WTCallback *)directMessageResponseCallback{
    return WTCallbackMake(self, @selector(directMessageResponse:info:), nil);
}
- (WTCallback *)directMessagesResponseCallback{
    return WTCallbackMake(self, @selector(directMessagesResponse:info:), nil);
}
- (void)directMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WeiboUnimplementedMethod
    // need sufficient app permission
}
- (void)directMessageResponse:(id)response info:(id)info{
    [responseCallback dissociateTarget];
    WeiboUnimplementedMethod
    // need sufficient app permission
}
- (void)directMessagesResponse:(id)response info:(id)info{
    [responseCallback dissociateTarget];
    WeiboUnimplementedMethod
    // need sufficient app permission
}

@end
