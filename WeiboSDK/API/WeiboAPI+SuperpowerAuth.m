//
//  WeiboAPI+DirectMessageAuth.m
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+SuperpowerAuth.h"
#import "WeiboAPI+Private.h"
#import "NSArray+WeiboAdditions.h"

NSString * const WeiboSuperpowerAppKey = @"82966982";
NSString * const WeiboSuperpowerAppSecret = @"72d4545a28a46a6f329c4f2b1e949e6a";
NSString * const WeiboSuperpowerOAuthRedirectURI = @"http://oauth.weico.cc";

@implementation WeiboAPI (DirectMessageAuth)

- (void)superpowerTokenWithUsername:(NSString *)username password:(NSString *)password
{
    NSAssert((username && password), @"direct message auth parameters must not be nil");
    
    username = [username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * params = @{
                              @"client_id" : WeiboSuperpowerAppKey,
                              @"client_secret" : WeiboSuperpowerAppSecret,
                              @"username" : username,
                              @"password" : password,
                              @"grant_type" : @"password"
                              };
    
    WeiboCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(superpowerTokenResponse:info:) info:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    
    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setMethod:@"POST"];
    [request setParameters:params];
    [request startRequest];
}

- (void)superpowerTokenWithAuthCode:(NSString *)code appKey:(NSString *)appkey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI
{
    appkey = appkey ? : WeiboSuperpowerAppKey;
    appSecret = appSecret ? : WeiboSuperpowerAppSecret;
    code = code ? : @"";
    redirectURI = redirectURI ? : WeiboSuperpowerOAuthRedirectURI;
    
    NSDictionary * params = @{@"client_id" : WeiboSuperpowerAppKey,
                              @"client_secret" : WeiboSuperpowerAppSecret,
                              @"code": code,
                              @"grant_type" : @"authorization_code",
                              @"redirect_uri": redirectURI};
    
    WeiboCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(superpowerTokenResponse:info:) info:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    
    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setMethod:@"POST"];
    [request setParameters:params];
    [request startRequest];
}

- (void)superpowerTokenResponse:(id)response info:(id __attribute__((unused)))info
{
    [responseCallback invoke:response];
}

@end
