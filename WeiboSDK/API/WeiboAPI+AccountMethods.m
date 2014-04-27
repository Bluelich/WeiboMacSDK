//
//  WeiboAPI+AccountMethods.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+Private.h"
#import "WeiboAPI+AccountMethods.h"

@implementation WeiboAPI (AccountMethods)

#pragma mark -
#pragma mark oAuth (xAuth)
- (void)clientAuthRequestAccessToken
{
    WeiboCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(clientAuthResponse:info:) info:nil];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:WEIBO_CONSUMER_KEY,@"client_id",WEIBO_CONSUMER_SECRET,@"client_secret",[authenticateWithAccount.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"username",authenticateWithAccount.password,@"password",@"password",@"grant_type", nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setMethod:@"POST"];
    [request setParameters:params];
    [request startRequest];
}
- (void)clientAuthResponse:(id)returnValue info:(id)info{
    [self oAuth2TokenResponse:returnValue info:info];
}

- (void)oAuth2TokenResponse:(id)returnValue info:(id)info{
    NSDictionary * dic = returnValue;
    NSString * token = [dic valueForKey:@"access_token"];
    NSTimeInterval expiresIn = [[dic valueForKey:@"expires_in"] intValue];
    [authenticateWithAccount setOAuth2Token:token];
    [authenticateWithAccount setExpireTime:expiresIn];
    [authenticateWithAccount verifyCredentials:responseCallback];
}

- (NSDictionary *)_queryStringToDictionary:(NSString *)string{
    NSArray * components = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];
    for (NSString * component in components) {
        if ([component length] == 0) continue;
        NSArray * keyAndValue = [component componentsSeparatedByString:@"="];
        if ([keyAndValue count] < 2) continue;
        NSString * value = [keyAndValue objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        [resultDictionary setValue:value forKey:[keyAndValue objectAtIndex:0]];
    }
    return resultDictionary;
}

@end
