//
//  WeiboAPI.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WTHTTPRequest.h"
#import "WeiboRequestError.h"
#import "WTCallback.h"
#import "WeiboAccount.h"
#import "WeiboComposition.h"

@interface WeiboAPI : NSObject
{
    NSString * apiRoot;
    WeiboAccount * authenticateWithAccount;
    WTCallback * responseCallback;
}

+ (id)requestWithAPIRoot:(NSString *)root callback:(WTCallback *)callback;
+ (id)authenticatedRequestWithAPIRoot:(NSString *)root 
                              account:(WeiboAccount *)account 
                             callback:(WTCallback *)callback;
- (id)initWithAccount:(WeiboAccount *)account
              apiRoot:(NSString *)root 
             callback:(WTCallback *)callback;

- (WTHTTPRequest *)baseRequestWithPartialURL:(NSString *)partialUrl;
- (WTHTTPRequest *)v1_baseRequestWithPartialURL:(NSString *)partialUrl;

- (NSString *)oauth2Token;
- (void)tokenDidExpire;

- (NSString *)keychainService;

@end