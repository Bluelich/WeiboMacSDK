//
//  WeiboAPI+Private.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"
#import "WeiboComposition.h"
#import "WeiboStatus.h"
#import "WeiboFavoriteStatus.h"
#import "WeiboComment.h"
#import "WeiboUser.h"
#import "WeiboAccount.h"
#import "WeiboRequestError.h"
#import "WeiboUnread.h"

#import "WTCallback.h"
#import "WTHTTPRequest.h"
#import "OAuthConsumer.h"
#import "WTOASingnaturer.h"

#import "WTFoundationUtilities.h"
#import "JSONKit.h"

@interface WeiboAPI (Private)

#pragma mark -
#pragma mark Request Core

- (void)request:(NSString *)partialUrl method:(NSString *)method parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WTCallback *)actualCallback;
- (void)v1_request:(NSString *)partialUrl
            method:(NSString *)method parameters:(NSDictionary *)parameters
 multipartFormData:(NSDictionary *)parts
          callback:(WTCallback *)actualCallback;
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WTCallback *)actualCallback;
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback;
- (void)v1_POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback;
- (void)GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback;
- (void)v1_GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback;

#pragma mark Response Handling
- (void)handleRequestError:(WeiboRequestError *)error;
- (void)_responseReceived:(id)responseValue callback:(WTCallback *)callback;
- (WTCallback *)errorlessCallbackWithCallback:(WTCallback *)callback;
- (WTCallback *)errorlessCallbackWithTarget:(id)target selector:(SEL)selector info:(id)info;

@end
