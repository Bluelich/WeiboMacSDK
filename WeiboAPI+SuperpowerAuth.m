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
    
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(superpowerTokenResponse:info:) info:nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"POST"];
    [request setParameters:params];
    [request startAuthrizedRequest];
}

- (void)superpowerTokenResponse:(id)response info:(id)info
{
    NSDictionary * dict = [response objectFromJSONString];
    
    [responseCallback invoke:dict];
}

@end
