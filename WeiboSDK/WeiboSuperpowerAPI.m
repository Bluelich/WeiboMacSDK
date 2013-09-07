//
//  WeiboSuperpowerAPI.m
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboSuperpowerAPI.h"
#import "WeiboAccount+Superpower.h"

@implementation WeiboSuperpowerAPI

- (NSString *)oauth2Token
{
    if (authenticateWithAccount.superpowerToken)
    {
        return authenticateWithAccount.superpowerToken;
    }
    return authenticateWithAccount.oAuth2Token;
}

- (void)tokenDidExpire
{
    authenticateWithAccount.superpowerTokenExpired = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerTokenExpiredNotification object:authenticateWithAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSuperpowerAuthorizeStateChangedNotification object:authenticateWithAccount];
}

@end
