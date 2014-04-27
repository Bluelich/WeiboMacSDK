//
//  WeiboHTTPResponse.m
//  Weibo
//
//  Created by Wutian on 14-4-27.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboHTTPResponse.h"

@interface WeiboHTTPResponse ()

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSString * responseString;
@property (nonatomic, strong) NSData * responseData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) WeiboRequestError * error;

@end

@implementation WeiboHTTPResponse

- (BOOL)success
{
    return self.statusCode == 200 && !self.error;
}

@end

@implementation WeiboHTTPResponse (AFNetworking)

+ (instancetype)responseWithAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation
{
    WeiboHTTPResponse * response = [WeiboHTTPResponse new];
    
    response.responseData = operation.responseData;
    response.responseObject = operation.responseObject;
    response.responseString = operation.responseString;
    response.statusCode = operation.response.statusCode;
    
    if (!response.success)
    {
        WeiboRequestError * requestError = [WeiboRequestError errorWithResponseString:operation.responseString statusCode:response.statusCode];
        response.error = requestError;
    }
    
    return response;
}

@end