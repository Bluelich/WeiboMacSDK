//
//  WeiboAPI.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WeiboHTTPRequest.h"
#import "WeiboRequestError.h"
#import "WeiboCallback.h"
#import "WeiboAccount.h"
#import "WeiboComposition.h"

@interface WeiboAPI : NSObject
{
    NSString * apiRoot;
    WeiboAccount * authenticateWithAccount;
    WeiboCallback * responseCallback;
    WeiboHTTPRequest * __weak runningRequest;
}

@property (nonatomic, weak, readonly) WeiboHTTPRequest * runningRequest;

+ (id)requestWithAPIRoot:(NSString *)root callback:(WeiboCallback *)callback;
+ (id)authenticatedRequestWithAPIRoot:(NSString *)root 
                              account:(WeiboAccount *)account 
                             callback:(WeiboCallback *)callback;
+ (instancetype)authenticatedRequestWithAPIRoot:(NSString *)root
                                        account:(WeiboAccount *)account
                                     completion:(WeiboCallbackBlock)completion;
- (id)initWithAccount:(WeiboAccount *)account
              apiRoot:(NSString *)root 
             callback:(WeiboCallback *)callback;

- (WeiboHTTPRequest *)baseRequestWithPartialURL:(NSString *)partialUrl;
- (WeiboHTTPRequest *)v1_baseRequestWithPartialURL:(NSString *)partialUrl;

- (NSString *)oauth2Token;
- (void)tokenDidExpire;

- (NSString *)keychainService;

@end
