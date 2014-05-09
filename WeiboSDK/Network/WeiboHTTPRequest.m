//
//  WeiboHTTPRequest.m
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboHTTPRequest.h"
#import "WeiboCallback.h"

#import <AFHTTPRequestOperationManager.h>

@interface WeiboHTTPRequest()

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) AFHTTPRequestSerializer * requestSerializer;

@property (nonatomic, weak) AFHTTPRequestOperation * runningOperation;

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
        self.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
        self.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        self.requestSerializer.timeoutInterval = 60;
        self.requestSerializer.HTTPShouldHandleCookies = NO;
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
        [self.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    
    NSMutableURLRequest * request = nil;
    
    if (self.multiparts)
    {
        request = [self.requestSerializer multipartFormRequestWithMethod:self.method URLString:self.url.absoluteString parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
        request = [self.requestSerializer requestWithMethod:self.method URLString:self.url.absoluteString parameters:self.parameters error:NULL];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.shouldUseCredentialStorage = NO;
    operation.securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    void __block (^completionBlock)(AFHTTPRequestOperation * opration) = ^(AFHTTPRequestOperation * operation) {
        self.runningOperation = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboHTTPRequestDidCompleteNotification object:nil];
        
        WeiboHTTPResponse * response = [WeiboHTTPResponse responseWithAFHTTPRequestOperation:operation];
        
        if (response.success)
        {
            [self.responseCallback invoke:response.responseObject];
        }
        else
        {
            [self.responseCallback invoke:response.error];
        }
    };;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(operation);
    }];
    
    if (self.uploadProgressBlock)
    {
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
            self.uploadProgressBlock(progress);
        }];
    }
    
    if (self.downloadProgressBlock)
    {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat progress = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
            self.downloadProgressBlock(progress);
        }];
    }
    
    if (!self.parsesJSON)
    {
        operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    else
    {
        AFHTTPResponseSerializer * serializer = [AFJSONResponseSerializer serializer];
        NSMutableSet * types = [[serializer acceptableContentTypes] mutableCopy];
        [types addObject:@"text/plain"];
        [types addObject:@"text/html"];
        [serializer setAcceptableContentTypes:types];
        
        operation.responseSerializer = serializer;
    }
    
    self.runningOperation = operation;
    
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:operation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWeiboHTTPRequestDidSendNotification object:nil];
}

- (void)cancelRequest
{
    if (self.runningOperation)
    {
        [self.runningOperation cancel];
    }
}

@end
