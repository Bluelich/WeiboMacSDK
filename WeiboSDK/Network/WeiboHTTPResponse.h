//
//  WeiboHTTPResponse.h
//  Weibo
//
//  Created by Wutian on 14-4-27.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboRequestError.h"

@interface WeiboHTTPResponse : NSObject

@property (nonatomic, strong, readonly) id responseObject;
@property (nonatomic, strong, readonly) NSString * responseString;
@property (nonatomic, strong, readonly) NSData * responseData;
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) WeiboRequestError * error;

// derived
@property (nonatomic, assign, readonly) BOOL success;

@end

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface WeiboHTTPResponse (AFNetworking)

+ (instancetype)responseWithAFHTTPRequestOperation:(AFHTTPRequestOperation *)operation;

@end
