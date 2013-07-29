//
//  WeiboRequestError.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WeiboErrorCodeInvaildRequest = 21323,
	WeiboErrorCodeTokenExpired = 21327,
    WeiboErrorCodeGrantTypeError = 21328,
    WeiboErrorCodeScopeAccessDenied = 21330,
    WeiboErrorCodeTokenInvalid = 21332,
} WeiboErrorCode;

@interface WeiboRequestError : NSError {
    NSString * requestURLString;
    NSInteger  errorDetailCode;
    NSString * errorString;
    NSString * errorStringInChinese;
}

@property (readonly, retain) NSString * requestURLString;
@property (readonly, assign) NSInteger  errorDetailCode;
@property (readonly, retain) NSString * errorString;
@property (readonly, retain) NSString * errorStringInChinese;

+ (WeiboRequestError *)errorWithResponseString:(NSString *)responseString statusCode:(int)code;
+ (WeiboRequestError *)errorWithHttpRequestError:(NSError *)error;
- (id)initWithResponseString:(NSString *)responseString statusCode:(int)code;
- (id)initWithHttpRequestError:(NSError *)error;
- (NSString *)message;

@end
