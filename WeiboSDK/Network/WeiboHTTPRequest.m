//
//  WeiboHTTPRequest.m
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboHTTPRequest.h"
#import "WeiboRequestError.h"
#import <AFHTTPRequestOperationManager.h>

#import "WeiboCallback.h"


@interface WeiboHTTPRequest()

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) AFHTTPRequestSerializer * serializer;

@end

@implementation WeiboHTTPRequest

+ (WeiboHTTPRequest *)requestWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)newURL
{
    if (self = [self init])
    {
        self.url = newURL;
        self.serializer = [[AFHTTPRequestSerializer alloc] init];
        self.serializer.stringEncoding = NSUTF8StringEncoding;
        self.serializer.timeoutInterval = 60;
        self.serializer.HTTPShouldHandleCookies = NO;
        self.method = @"GET";
        self.parsesJSON = YES;
    }
    return self;
}

- (void)startRequest
{
    if (self.oAuth2Token)
    {
        NSString * authorization = [NSString stringWithFormat:@"OAuth2 %@",self.oAuth2Token];
        [self.serializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    
    NSMutableURLRequest * request = nil;
    
    if (self.multiparts)
    {
        request = [self.serializer multipartFormRequestWithMethod:self.method URLString:self.url.absoluteString parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [self.multiparts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSData class]])
                {
                    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
                    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", key, key] forKey:@"Content-Disposition"];
                    [formData appendPartWithHeaders:mutableHeaders body:obj];
                }
            }];
        } error:NULL];
    }
    else
    {
        request = [self.serializer requestWithMethod:self.method URLString:self.url.absoluteString parameters:self.parameters error:NULL];
    }
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished:operation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished:operation];
    }];
    
    if (!self.parsesJSON)
    {
        operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:operation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboHTTPRequestDidSendNotification object:nil];
}


#pragma mark -
#pragma mark Responses

- (void)requestError:(AFHTTPRequestOperation *)operation
{
    WeiboRequestError * requestError = [WeiboRequestError errorWithResponseString:operation.responseString statusCode:operation.response.statusCode];
    [self.responseCallback invoke:requestError];
}
- (void)requestSuccess:(AFHTTPRequestOperation *)operation
{
    [self.responseCallback invoke:operation.responseObject];
}

- (void)requestFinished:(AFHTTPRequestOperation *)operation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboHTTPRequestDidCompleteNotification object:nil];
    
    if (operation.response.statusCode == 200)
    {
        [self requestSuccess:operation];
    }
    else
    {
        [self requestError:operation];
    }
}

@end
