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
- (void)unreadCountSinceID:(WeiboStatusID)since{
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(unreadCountResponse:info:) info:nil];
    NSDictionary * param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",authenticateWithAccount.user.userID] forKey:@"uid"];
    
    NSString * urlString = OFFLINE_DEBUG_MODE?@"http://localhost/remind/unread_count.json":@"https://rm.api.weibo.com/2/remind/unread_count.json";
    NSURL * url = [NSURL URLWithString:urlString];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"GET"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startAuthrizedRequest];
}
- (void)unreadCount{
    [self unreadCountSinceID:0];
}
- (void)unreadCountResponse:(id)response info:(id)info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        [responseCallback dissociateTarget];
        return;
    }
    [WeiboUnread parseUnreadJSON:response onComplete:^(id object) {
        [responseCallback invoke:object];
    }];
}
- (void)v1_resetUnreadWithType:(WeiboUnreadCountType)type{
    WTCallback * callback = WTCallbackMake(self, @selector(resetUnreadResponse:info:), nil);
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",type]
                                        forKey:@"type"];
    [self v1_POST:@"statuses/reset_count.json" parameters:param callback:callback];
}
- (void)resetUnreadWithType:(WeiboUnreadCountType)type{
    if (type == WeiboUnreadCountTypeStatus) {
        // Weibo Open API auto reset status count now.
        return;
    }
    
    WTCallback * callback = WTCallbackMake(self, @selector(resetUnreadResponse:info:), nil);
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
        default:{
            [callback dissociateTarget];
            return;
        }
    }
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:typeString forKey:@"type"];
    NSURL * url = [NSURL URLWithString:@"https://rm.api.weibo.com/2/remind/set_count.json"];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"POST"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startAuthrizedRequest];
}
- (void)resetUnreadResponse:(id)response info:(id)info{
    // Not Implemented Yet.
    [responseCallback dissociateTarget];
}

@end
