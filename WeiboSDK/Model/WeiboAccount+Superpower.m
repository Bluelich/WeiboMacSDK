//
//  WeiboAccount+Superpower.m
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Superpower.h"
#import "WeiboAPI+SuperpowerAuth.h"
#import "NSDictionary+WeiboAdditions.h"
#import "WeiboSuperpowerAPI.h"
#import "SSKeychain.h"
#import "WTCallback.h"
#import "WeiboDirectMessagesConversationManager.h"
#import "Weibo.h"

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

- (WeiboAPI *)authenticatedSuperpowerRequest:(WTCallback *)callback
{
    return [WeiboSuperpowerAPI authenticatedRequestWithAPIRoot:self.apiRoot account:self callback:callback];
}

- (void)authorizeSuperpowerWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    if (_flags.superpowerAuthorizing) return;
    
    WeiboAPI * api = [self authenticatedRequest:WTCallbackMake(self, @selector(superpowerAuthorizeResponse:info:), nil)];
    
    [api superpowerTokenWithUsername:aUsername password:aPassword];
}

- (void)superpowerAuthorizeFailedWithError:(WeiboRequestError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeFailedNotification object:self userInfo:@{@"error":error}];
}

- (void)superpowerAuthorizeResponse:(id)response info:(id)info
{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        [self superpowerAuthorizeFailedWithError:response];
    }
    else if ([response isKindOfClass:[NSDictionary class]])
    {
        NSString * token = [response stringForKey:@"access_token" defaultValue:nil];
        WeiboUserID userID = [response longlongForKey:@"uid" defaultValue:0];
        
        if (userID != self.user.userID)
        {
            WeiboRequestError * error = [WeiboRequestError errorWithCode:WeiboErrorCodeSuperpowerUserNotMatch];
            
            [self superpowerAuthorizeFailedWithError:error];
        }
        else
        {
            self.superpowerTokenExpired = NO;
            self.superpowerToken = token;
            
            if (token)
            {
                [self updateSuperpowerTokenToKeychain:token];
            }
            
            [self refreshDirectMessages];
            
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
