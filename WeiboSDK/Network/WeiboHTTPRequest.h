//
//  WeiboHTTPRequest.h
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>
#import "WeiboHTTPResponse.h"

@class WTMutableMultiDictionary, WeiboCallback;

@interface WeiboHTTPRequest : NSObject

+ (WeiboHTTPRequest *)requestWithURL:(NSURL *)url;

@property (nonatomic, strong) WeiboCallback * responseCallback;
@property (nonatomic, strong) NSString * oAuth2Token;
@property (nonatomic, strong) NSString * method;
@property (nonatomic, strong) NSDictionary * parameters;
@property (nonatomic, strong) NSDictionary * multiparts;
@property (nonatomic, assign) BOOL parsesJSON; // default to YES

@property (nonatomic, copy) void (^uploadProgressBlock)(CGFloat progress);
@property (nonatomic, copy) void (^downloadProgressBlock)(CGFloat progress);

- (Promise *)startRequest;
- (void)cancelRequest;

@end
