//
//  WeiboRequestError.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    // Error codes defined by open.weibo.com
    WeiboErrorCodeInvaildRequest = 21323,
	WeiboErrorCodeTokenExpired = 21327,
    WeiboErrorCodeGrantTypeError = 21328,
    WeiboErrorCodeScopeAccessDenied = 21330,
    WeiboErrorCodeTokenInvalid = 21332,
    WeiboErrorCodeAlreadyFollowed = 20506,
    WeiboErrorCodeNotFollowing = 20522,
    WeiboErrorCodeAlreadyFavorited = 20704,
    WeiboErrorCodeNotFavorited = 20705,
    
    // Error codes defined by SDK
    WeiboErrorCodeSuperpowerUserNotMatch = 929001,
} WeiboErrorCode;

@interface WeiboRequestError : NSError {
    NSString * requestURLString;
    NSInteger  errorDetailCode;
    NSString * errorString;
    NSString * errorStringInChinese;
}

@property (readonly, strong) NSString * requestURLString;
@property (readonly, assign) NSInteger  errorDetailCode;
@property (readonly, strong) NSString * errorString;
@property (readonly, strong) NSString * errorStringInChinese;

+ (WeiboRequestError *)errorWithCode:(NSInteger)code;
+ (WeiboRequestError *)errorWithResponseString:(NSString *)responseString statusCode:(int)code;
+ (WeiboRequestError *)errorWithHttpRequestError:(NSError *)error;

- (id)initWithResponseString:(NSString *)responseString statusCode:(int)code;
- (id)initWithHttpRequestError:(NSError *)error;
- (NSString *)message;

@end
