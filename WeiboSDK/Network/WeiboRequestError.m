//
//  WeiboRequestError.m
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboRequestError.h"
#import "JSONKit.h"

NSString * const WeiboRequestErrorDomain = @"WeiboRequestErrorDomain";

@interface WeiboRequestError()
- (NSDictionary *)parseResponseToDictionaryWithString:(NSString *)string;
@end

@implementation WeiboRequestError
@synthesize requestURLString, errorDetailCode, errorString, errorStringInChinese;

+ (WeiboRequestError *)errorWithCode:(NSInteger)code
{
    return [[self alloc] initWithDomain:WeiboRequestErrorDomain code:code userInfo:nil];
}

+ (WeiboRequestError *)errorWithResponseString:(NSString *)responseString statusCode:(NSInteger)code
{
    return [[self alloc] initWithResponseString:responseString statusCode:code];
}

+ (WeiboRequestError *)errorWithHttpRequestError:(NSError *)error{
    return [[self alloc] initWithHttpRequestError:error];
}

/*
 // error response example: 
 request=/oauth/access_token
 &error_code=403
 &error=40307:Error:+HTTP+METHOD+is+not+suported+for+this+request!
 &error_CN=错误:请求的HTTP+METHOD不支持!
 */
/*
 {"request":"/statuses/update.json","error_code":"400","error":"40025:Error: repeated weibo text!"}
 */
- (id)initWithResponseString:(NSString *)responseString statusCode:(NSInteger)code
{
    NSDictionary * resultDictionary = [self parseResponseToDictionaryWithString:responseString];
    NSInteger error_code = code;
    if ([resultDictionary valueForKey:@"error_code"]) {
        error_code = [[resultDictionary valueForKey:@"error_code"] intValue];
    }
    if ((self = [super initWithDomain:WeiboRequestErrorDomain code:error_code userInfo:nil])) {
        NSDictionary * resultDictionary = [self parseResponseToDictionaryWithString:responseString];
        requestURLString = [resultDictionary valueForKey:@"request"];
        errorDetailCode = [[resultDictionary valueForKey:@"error_detail_code"] intValue];
        errorString = [resultDictionary valueForKey:@"error"];
        NSString * errorDescription = [resultDictionary valueForKey:@"error_description"];
        if (errorDescription) {
            errorString = errorDescription;
        }
        
        NSString * errorInCN = [resultDictionary valueForKey:@"error_CN"];
        if (errorInCN) {
            errorStringInChinese = errorInCN;
        }else {
            errorStringInChinese = errorString;
        }
    }
    return self;
}

- (id)initWithHttpRequestError:(NSError *)error{
    NSString * eString = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
    if ((self = [super initWithDomain:[error domain] code:[error code] userInfo:nil])) {
        errorString = eString;
    }
    return self;
}


- (NSString *)description
{
    NSMutableString * string = [NSMutableString string];
    [string appendFormat:@"There is a error in %@",self.domain];
    if (requestURLString) {
        [string appendFormat:@", is a request to: %@",requestURLString];
    }
    if (self.code > 0) {
        [string appendFormat:@", an error with code %ld was occurred",self.code];
    }
    if (errorDetailCode > 0) {
        [string appendFormat:@", has detail code: %ld",errorDetailCode];
    }
    if (errorString) {
        [string appendFormat:@", reason: %@",errorString];
    }
    if (errorStringInChinese) {
        [string appendFormat:@" ( %@ )",errorStringInChinese];
    }
    [string appendFormat:@". "];
    return string;
}
- (NSString *)message{
    NSMutableString * string = [NSMutableString string];
    
    NSString * desc = (errorStringInChinese?:errorString)?:@"";
    [string appendString:desc];
    [string appendFormat:@" ( 错误代码:%ld",self.code];
    if (errorDetailCode > 0) {
        [string appendFormat:@" , 详细代码:%ld",errorDetailCode];
    }
    [string appendString:@" )"];
    return string;
}

- (NSDictionary *)parseWithQueryString:(NSString *)string{
    string = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray * components = [string componentsSeparatedByString:@"&"];
    NSDictionary * resultDictionary = [NSMutableDictionary dictionary];
    for (NSString * component in components) {
        if ([component length] == 0) continue;
        NSArray * keyAndValue = [component componentsSeparatedByString:@"="];
        if ([keyAndValue count] < 2) continue;
        NSString * value = [keyAndValue objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        [resultDictionary setValue:value forKey:[keyAndValue objectAtIndex:0]];
    }
    NSString * eString = [resultDictionary valueForKey:@"error"];
    if (eString) {
        NSString * detailCodeString = [eString substringToIndex:5];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber* number = [numberFormatter numberFromString:detailCodeString];
        if (number) {
            eString = [eString substringFromIndex:6];
            [resultDictionary setValue:eString forKey:@"error"];
            [resultDictionary setValue:number forKey:@"error_detail_code"];
        }
    }
    return resultDictionary;
}
- (NSDictionary *)parseWithJSONString:(NSString *)string{
    NSDictionary * dic = [string objectFromJSONString];
    NSDictionary * resultDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString * eString = [resultDictionary valueForKey:@"error"];
    if (eString) {
        NSString * detailCodeString = [eString substringToIndex:5];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber* number = [numberFormatter numberFromString:detailCodeString];
        if (number) {
            eString = [eString substringFromIndex:6];
            [resultDictionary setValue:eString forKey:@"error"];
            [resultDictionary setValue:number forKey:@"error_detail_code"];
        }
    }
    return resultDictionary;
}
- (NSDictionary *)parseResponseToDictionaryWithString:(NSString *)string{
    if ([string hasPrefix:@"{"]) {
        return [self parseWithJSONString:string];
    } else {
        return [self parseWithQueryString:string];
    }
    
}


@end
