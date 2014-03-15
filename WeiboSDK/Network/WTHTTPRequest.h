//
//  WTHTTPRequest.h
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@class WTMutableMultiDictionary, WTCallback;

@interface WTHTTPRequest : ASIFormDataRequest <ASIHTTPRequestDelegate> {
    WTCallback * responseCallback;
    NSString *oAuthToken;
    NSString *oAuthTokenSecret;
    NSString *oAuth2Token;
    NSDictionary * parameters;
}

@property(strong, nonatomic) WTCallback *responseCallback;
@property(strong, nonatomic) NSString *oAuthToken;
@property(strong, nonatomic) NSString *oAuthTokenSecret;
@property(strong, nonatomic) NSString *oAuth2Token;
@property(strong, nonatomic) NSDictionary * parameters;

+ (WTHTTPRequest *)requestWithURL:(NSURL *)url;
- (void)v1_startAuthrizedRequest;
- (void)startAuthrizedRequest;

@end
