//
//  WeiboRequestError.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
