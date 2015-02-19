//
//  WeiboAccount+Superpower.h
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"

extern NSString * const WeiboAccountSuperpowerAuthorizeFinishedNotification;
extern NSString * const WeiboAccountSuperpowerAuthorizeFailedNotification;
extern NSString * const WeiboAccountSuperpowerTokenExpiredNotification;
extern NSString * const WeiboAccountSuperpowerAuthorizeStateChangedNotification;

@interface WeiboAccount (Superpower)

@property (nonatomic, assign, readonly) BOOL superpowerAuthorized;

- (WeiboAPI *)authenticatedSuperpowerRequest:(WeiboCallback *)callback;
- (WeiboAPI *)authenticatedSuperpowerRequestWithCompletion:(WeiboCallbackBlock)completion;
- (void)authorizeSuperpowerWithUsername:(NSString *)username password:(NSString *)password;
- (void)authorizeSuperpowerWithAuthCode:(NSString *)code appKey:(NSString *)appkey appSecret:(NSString *)appSecret redirectURI:(NSString *)uri;
- (void)deauthorizeSuperpower;

- (void)restoreSuperpowerTokenFromKeychain;
- (void)updateSuperpowerTokenToKeychain:(NSString *)token;

@end
