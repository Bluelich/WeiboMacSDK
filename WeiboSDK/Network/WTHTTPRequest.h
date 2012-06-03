//
//  WTHTTPRequest.h
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#import "WeiboAppInfo.h"
/*
 Create your own, contains:
 #define WEIBO_CONSUMER_KEY @"12345"
 #define WEIBO_CONSUMER_SECRET @"1234567890"
*/

@class WTMutableMultiDictionary, WTCallback;

@interface WTHTTPRequest : ASIFormDataRequest <ASIHTTPRequestDelegate> {
    WTCallback * responseCallback;
    NSString *oAuthToken;
    NSString *oAuthTokenSecret;
    NSString *oAuth2Token;
    NSDictionary * parameters;
}

@property(retain, nonatomic) WTCallback *responseCallback;
@property(retain, nonatomic) NSString *oAuthToken;
@property(retain, nonatomic) NSString *oAuthTokenSecret;
@property(retain, nonatomic) NSString *oAuth2Token;
@property(retain, nonatomic) NSDictionary * parameters;

+ (WTHTTPRequest *)requestWithURL:(NSURL *)url;
- (void)v1_startAuthrizedRequest;
- (void)startAuthrizedRequest;

@end
