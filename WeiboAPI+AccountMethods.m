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
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(clientAuthResponse:info:) info:nil];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:WEIBO_CONSUMER_KEY,@"client_id",WEIBO_CONSUMER_SECRET,@"client_secret",[authenticateWithAccount.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"username",authenticateWithAccount.password,@"password",@"password",@"grant_type", nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"POST"];
    [request setParameters:params];
    [request startAuthrizedRequest];
}
- (void)clientAuthResponse:(id)returnValue info:(id)info{
    [self oAuth2TokenResponse:returnValue info:info];
}
- (void)xAuthRequestAccessTokens{
    WTCallback * callback = [self errorlessCallbackWithTarget:self
                                                     selector:@selector(xAuthMigrateResponse:info:)
                                                         info:nil];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 authenticateWithAccount.username,@"x_auth_username",
                                 authenticateWithAccount.password,@"x_auth_password",
                                 @"client_auth",@"x_auth_mode", nil];
    [self v1_POST:@"oauth/access_token" parameters:parameters callback:callback];
}

- (void)xAuthMigrateResponse:(id)returnValue info:(id)info{
    NSDictionary * resultDictionary = [self _queryStringToDictionary:returnValue];
    NSString * token = [resultDictionary valueForKey:@"oauth_token"];
    NSString * tokenSecret = [resultDictionary valueForKey:@"oauth_token_secret"];
    [authenticateWithAccount setOAuthToken:token];
    [authenticateWithAccount setOAuthTokenSecret:tokenSecret];
    [self oAuth2RequestTokenByAccessToken];
}
- (void)oAuth2RequestTokenByAccessToken{
    WTCallback * callback = [self errorlessCallbackWithTarget:self
                                                     selector:@selector(oAuth2TokenResponse:info:)
                                                         info:nil];
    [self v1_POST:@"oauth2/get_oauth2_token" parameters:nil callback:callback];
}
- (void)oAuth2TokenResponse:(id)returnValue info:(id)info{
    NSString * tokenResponse = returnValue;
    NSDictionary * dic = [tokenResponse objectFromJSONString];
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
