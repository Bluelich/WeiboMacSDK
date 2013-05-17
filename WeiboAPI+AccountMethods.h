//
//  WeiboAPI+AccountMethods.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (AccountMethods)

#pragma mark -
#pragma mark oAuth (xAuth)
- (void)clientAuthRequestAccessToken;
- (void)xAuthRequestAccessTokens;
- (void)oAuth2RequestTokenByAccessToken;

@end
