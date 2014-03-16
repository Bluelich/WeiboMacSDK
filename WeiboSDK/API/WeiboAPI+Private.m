//
//  WeiboAPI+Private.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+Private.h"
#import "WeiboHTTPRequest.h"

@implementation WeiboAPI (Private)

#pragma mark -
#pragma mark Request Core

- (void)request:(NSString *)partialUrl
         method:(NSString *)method parameters:(NSDictionary *)parameters
multipartFormData:(NSDictionary *)parts
       callback:(WTCallback *)actualCallback
{
    WTCallback * callback = [self errorlessCallbackWithCallback:actualCallback];
    WeiboHTTPRequest * request = [self baseRequestWithPartialURL:partialUrl];
    [request setResponseCallback:callback];
    [request setMethod:method];
    [request setParameters:parameters];
    [request setMultiparts:parts];
    [request setOAuth2Token:self.oauth2Token];
    [request startRequest];
}

- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WTCallback *)actualCallback{
    [self request:partialUrl method:@"POST" parameters:parameters multipartFormData:(NSDictionary *)parts callback:actualCallback];
}
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self POST:partialUrl parameters:parameters multipartFormData:nil callback:actualCallback];
}
- (void)GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self request:partialUrl method:@"GET" parameters:parameters multipartFormData:(NSDictionary *)nil callback:actualCallback];
}

#pragma mark Response Handling
- (void)handleRequestError:(WeiboRequestError *)error
{
    LogIt([error description]);
    if (error.code == WeiboErrorCodeTokenExpired ||
        error.code == WeiboErrorCodeTokenInvalid) {
        [self tokenDidExpire];
    }
}

- (void)_responseReceived:(id)responseValue callback:(WTCallback *)callback
{    
    if ([responseValue isKindOfClass:[WeiboRequestError class]])
    {
        [self handleRequestError:responseValue];
        if (callback != responseCallback)
        {
            [callback dissociateTarget];
        }
        [responseCallback invoke:responseValue];
    }
    else
    {
        [callback invoke:responseValue];
    }
}

- (WTCallback *)errorlessCallbackWithCallback:(WTCallback *)callback{
    return [WTCallback callbackWithTarget:self
                                 selector:@selector(_responseReceived:callback:)
                                     info:callback];
}
- (WTCallback *)errorlessCallbackWithTarget:(id)target selector:(SEL)selector info:(id)info{
    WTCallback * actualCallback = [WTCallback callbackWithTarget:target
                                                        selector:selector
                                                            info:nil];
    return [self errorlessCallbackWithCallback:actualCallback];
}


@end
