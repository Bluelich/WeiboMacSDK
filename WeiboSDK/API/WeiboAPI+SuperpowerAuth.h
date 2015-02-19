//
//  WeiboAPI+DirectMessageAuth.h
//  Weibo
//
//  Created by Wutian on 13-8-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (superpowerAuth)

- (void)superpowerTokenWithUsername:(NSString *)username password:(NSString *)password;
- (void)superpowerTokenWithAuthCode:(NSString *)code appKey:(NSString *)appkey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI;

@end
