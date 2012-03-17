//
//  WTHTTPRequest.h
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#define WEIBO_CONSUMER_KEY @"83996567"
#define WEIBO_CONSUMER_SECRET @"d3ae350c39c5f12be40e4c7fc389266d"

@class WTMutableMultiDictionary, WTCallback;

@interface WTHTTPRequest : ASIFormDataRequest <ASIHTTPRequestDelegate> {
    WTCallback * responseCallback;
    NSString *oAuthToken;
    NSString *oAuthTokenSecret;
    NSDictionary * parameters;
}

@property(retain, nonatomic) WTCallback *responseCallback;
@property(retain, nonatomic) NSString *oAuthToken;
@property(retain, nonatomic) NSString *oAuthTokenSecret;
@property(retain, nonatomic) NSDictionary * parameters;

+ (WTHTTPRequest *)requestWithURL:(NSURL *)url;
- (void)startAuthrizedRequest;

@end
