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

@interface WeiboAccount (Superpower)

@property (nonatomic, assign, readonly) BOOL superpowerAuthorized;

- (WeiboAPI *)authenticatedSuperpowerRequest:(WTCallback *)callback;
- (void)authorizeSuperpowerWithUsername:(NSString *)username password:(NSString *)password;

- (void)restoreSuperpowerTokenFromKeychain;
- (void)updateSuperpowerTokenToKeychain:(NSString *)token;

@end
