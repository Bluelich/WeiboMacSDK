//
//  WeiboHTTPRequest.h
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTMutableMultiDictionary, WTCallback;

@interface WeiboHTTPRequest : NSObject

+ (WeiboHTTPRequest *)requestWithURL:(NSURL *)url;

@property (nonatomic, strong) WTCallback * responseCallback;
@property (nonatomic, strong) NSString * oAuth2Token;
@property (nonatomic, strong) NSString * method;
@property (nonatomic, strong) NSDictionary * parameters;
@property (nonatomic, strong) NSDictionary * multiparts;

- (void)startRequest;

@end
