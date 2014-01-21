//
//  WeiboAPI.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"
#import "WeiboAPI+Private.h"
#import "Weibo.h"

@implementation WeiboAPI

#pragma mark Object Lifecycle
+ (id)requestWithAPIRoot:(NSString *)root callback:(WTCallback *)callback{
    return [[[self alloc] initWithAccount:nil apiRoot:root callback:callback] autorelease];
}
+ (id)authenticatedRequestWithAPIRoot:(NSString *)root 
                              account:(WeiboAccount *)account 
                             callback:(WTCallback *)callback{
    return [[[self alloc] initWithAccount:account 
                                  apiRoot:root 
                                 callback:callback] autorelease];
}
- (id)initWithAccount:(WeiboAccount *)account
              apiRoot:(NSString *)root 
             callback:(WTCallback *)callback{
    if ((self = [super init])) {
        apiRoot = [root retain];
        authenticateWithAccount = [account retain];
        responseCallback = [callback retain];
    }
    return self;
}
- (void)dealloc{
    [apiRoot release]; apiRoot = nil;
    [authenticateWithAccount release]; authenticateWithAccount = nil;
    [responseCallback release]; responseCallback = nil;
    [super dealloc];
}

- (NSString *)oauth2Token
{
    return authenticateWithAccount.oAuth2Token;
}

- (void)tokenDidExpire
{
    authenticateWithAccount.tokenExpired = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboAccessTokenExpriedNotification object:authenticateWithAccount];
}

- (NSString *)keychainService
{
    return [Weibo globalKeychainService];
}

- (WTHTTPRequest *)baseRequestWithPartialURL:(NSString *)partialUrl{
    return [WTHTTPRequest requestWithURL:[NSURL URLWithString:partialUrl
                                                relativeToURL:[NSURL URLWithString:OFFLINE_DEBUG_MODE?@"http://127.0.0.1/":apiRoot]]];
}
- (WTHTTPRequest *)v1_baseRequestWithPartialURL:(NSString *)partialUrl{
    return [WTHTTPRequest requestWithURL:[NSURL URLWithString:partialUrl
                                                relativeToURL:[NSURL URLWithString:WEIBO_APIROOT_V1]]];
}

@end
