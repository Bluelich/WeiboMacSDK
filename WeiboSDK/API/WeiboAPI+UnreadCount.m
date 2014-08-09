//
//  WeiboAPI+UnreadCount.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+Private.h"
#import "WeiboAPI+UnreadCount.h"

@implementation WeiboAPI (UnreadCount)

#pragma mark -
#pragma mark Other
- (void)unreadCountSinceID:(WeiboStatusID __attribute__((unused)))since{
    WeiboCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(unreadCountResponse:info:) info:nil];
    NSDictionary * param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",authenticateWithAccount.user.userID] forKey:@"uid"];
    
    NSURL * url = [NSURL URLWithString:@"https://rm.api.weibo.com/2/remind/unread_count.json"];
    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setMethod:@"GET"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startRequest];
}
- (void)unreadCount{
    [self unreadCountSinceID:0];
}
- (void)unreadCountResponse:(id)response info:(id __attribute__((unused)))info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        [responseCallback dissociateTarget];
        return;
    }
    [WeiboUnread parseObjectWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}

- (void)resetUnreadWithType:(WeiboUnreadCountType)type{
    if (type == WeiboUnreadCountTypeStatus) {
        // Weibo Open API auto reset status count now.
        return;
    }
    
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(resetUnreadResponse:info:), nil);
    NSString * typeString = nil;
    switch (type) {
        case WeiboUnreadCountTypeStatus:
            typeString = @"status";
            break;
        case WeiboUnreadCountTypeFollower:
            typeString = @"follower";
            break;
        case WeiboUnreadCountTypeComment:
            typeString = @"cmt";
            break;
        case WeiboUnreadCountTypeDirectMessage:
            typeString = @"dm";
            break;
        case WeiboUnreadCountTypeStatusMention:
            typeString = @"mention_status";
            break;
        case WeiboUnreadCountTypeCommentMention:
            typeString = @"mention_cmt";
            break;
        default:{
            [callback dissociateTarget];
            return;
        }
    }
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:typeString forKey:@"type"];
    NSURL * url = [NSURL URLWithString:@"https://rm.api.weibo.com/2/remind/set_count.json"];
    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setMethod:@"POST"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startRequest];
}
- (void)resetUnreadResponse:(id __attribute__((unused)))response info:(id __attribute__((unused)))info{
    // Not Implemented Yet.
    [responseCallback dissociateTarget];
}

@end
