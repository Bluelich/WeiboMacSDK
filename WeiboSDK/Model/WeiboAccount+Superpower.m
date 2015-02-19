//
//  WeiboAccount+Superpower.m
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Superpower.h"
#import "WeiboAPI+SuperpowerAuth.h"
#import "WeiboSuperpowerAPI.h"
#import "SSKeychain.h"
#import "WeiboCallback.h"
#import "WeiboDirectMessagesConversationManager.h"
#import "Weibo.h"
#import <NSDictionary+Accessors.h>

NSString * const WeiboAccountSuperpowerAuthorizeFinishedNotification = @"WeiboAccountSuperpowerAuthorizeFinishedNotification";
NSString * const WeiboAccountSuperpowerAuthorizeFailedNotification = @"WeiboAccountSuperpowerAuthorizeFailedNotification";
NSString * const WeiboAccountSuperpowerTokenExpiredNotification = @"WeiboAccountSuperpowerTokenExpiredNotification";
NSString * const WeiboAccountSuperpowerAuthorizeStateChangedNotification = @"WeiboAccountSuperpowerAuthorizeStateChangedNotification";

@implementation WeiboAccount (Superpower)

- (BOOL)superpowerAuthorized
{
    if (self.superpowerTokenExpired)
    {
        return NO;
    }
    
    return self.superpowerToken != nil;
}

#pragma mark - Authorizing

- (WeiboAPI *)authenticatedSuperpowerRequest:(WeiboCallback *)callback
{
    return [WeiboSuperpowerAPI authenticatedRequestWithAPIRoot:self.apiRoot account:self callback:callback];
}
- (WeiboAPI *)authenticatedSuperpowerRequestWithCompletion:(WeiboCallbackBlock)completion
{
    return [self authenticatedSuperpowerRequest:WeiboBlockCallback(completion)];
}

- (void)authorizeSuperpowerWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    if (_flags.superpowerAuthorizing) return;
    
    WeiboAPI * api = [self authenticatedRequest:WeiboCallbackMake(self, @selector(superpowerAuthorizeResponse:info:), nil)];
    
    [api superpowerTokenWithUsername:aUsername password:aPassword];
}

- (void)authorizeSuperpowerWithAuthCode:(NSString *)code appKey:(NSString *)appkey appSecret:(NSString *)appSecret redirectURI:(NSString *)uri
{
    if (_flags.superpowerAuthorizing) return;
    
    WeiboAPI * api = [self authenticatedRequest:WeiboCallbackMake(self, @selector(superpowerAuthorizeResponse:info:), nil)];
    
    [api superpowerTokenWithAuthCode:code appKey:appkey appSecret:appSecret redirectURI:uri];
}

- (void)superpowerAuthorizeFailedWithError:(WeiboRequestError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeFailedNotification object:self userInfo:@{@"error":error}];
}

- (void)superpowerAuthorizeResponse:(id)response info:(id __attribute__((unused)))info
{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        [self superpowerAuthorizeFailedWithError:response];
    }
    else if ([response isKindOfClass:[NSDictionary class]])
    {
        NSString * token = [(NSDictionary *)response stringForKey:@"access_token"];
        WeiboUserID userID = (WeiboUserID)[(NSDictionary *)response longLongForKey:@"uid"];
        
        if (userID != self.user.userID)
        {
            WeiboRequestError * error = [WeiboRequestError errorWithCode:WeiboErrorCodeSuperpowerUserNotMatch];
            
            [self superpowerAuthorizeFailedWithError:error];
        }
        else
        {
            self.superpowerTokenExpired = NO;
            self.superpowerToken = token;
            
            [self refreshPublicMessage];
            [self refreshPrivateMessages];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeStateChangedNotification object:self];
            
            [[Weibo sharedWeibo] saveCurrentState];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeFinishedNotification object:self];
}

- (void)deauthorizeSuperpower
{
    self.superpowerToken = nil;
    self.superpowerTokenExpired = NO;
    
    [self updateSuperpowerTokenToKeychain:nil];
    [[Weibo sharedWeibo] saveCurrentState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeStateChangedNotification object:self];
}

#pragma mark - Keychain

- (NSString *)superpowerKeychainAccount
{
    return [NSString stringWithFormat:@"superpower_token:%lld", self.user.userID];
}

- (void)restoreSuperpowerTokenFromKeychain
{
    NSString * token = [SSKeychain passwordForService:self.keychainService account:[self superpowerKeychainAccount]];
    
    if (token)
    {
        self.superpowerToken = token;
    }
}
- (void)updateSuperpowerTokenToKeychain:(NSString *)token
{
    if (!token)
    {
        [SSKeychain deletePasswordForService:self.keychainService account:[self superpowerKeychainAccount]];
    }
    else
    {
        [SSKeychain setPassword:token forService:self.keychainService account:[self superpowerKeychainAccount]];
    }
}


@end
