//
//  WeiboShortURLManager.m
//  Weibo
//
//  Created by Wutian on 14-2-15.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboShortURLManager.h"

@interface WeiboShortURLManager ()
{
    struct {
        unsigned int scheduledRequest: 1;
    } _flags;
}

@property (nonatomic, strong) NSMutableDictionary * shortURLs;
@property (nonatomic, strong) NSMutableArray * taskQueue;

@end

@implementation WeiboShortURLManager

+ (instancetype)defaultManager
{
    static WeiboShortURLManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WeiboShortURLManager new];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        self.shortURLs = [NSMutableDictionary dictionary];
        self.taskQueue = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 

#pragma mark - Request

- (void)setNeedsRequest
{
    if (!_flags.scheduledRequest)
    {
        _flags.scheduledRequest = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self batchRequest];
        });
    }
}

- (void)batchRequest
{
    _flags.scheduledRequest = NO;
    
}

- (void)enqueueShortURL:(NSString *)shortURL
{
    
}

@end
