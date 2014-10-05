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
#import "WeiboHTTPRequest.h"

#import "WeiboCallback.h"
#import "WeiboFoundationUtilities.h"
#import "JSONKit.h"

@interface WeiboAPI (Private)

#pragma mark -
#pragma mark Request Core

- (void)request:(NSString *)partialUrl method:(NSString *)method parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WeiboCallback *)actualCallback;
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WeiboCallback *)actualCallback;
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WeiboCallback *)actualCallback;
- (void)GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WeiboCallback *)actualCallback;

#pragma mark Response Handling
- (void)handleRequestError:(WeiboRequestError *)error;
- (void)_responseReceived:(id)responseValue callback:(WeiboCallback *)callback;
- (WeiboCallback *)errorlessCallbackWithCallback:(WeiboCallback *)callback;
- (WeiboCallback *)errorlessCallbackWithTarget:(id)target selector:(SEL)selector info:(id)info;

- (void)requestFailedWithError:(NSError *)error;
- (void)requestFailedWithErrorCode:(WeiboErrorCode)code;

@end
