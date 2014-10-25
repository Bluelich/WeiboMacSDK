//
//  WeiboShortURLManager.m
//  Weibo
//
//  Created by Wutian on 14-2-15.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboShortURLManager.h"
#import "WeiboExpandedURL.h"
#import "WeiboAPI+ShortURL.h"
#import "Weibo.h"

NSString * const WeiboShortURLManagerBatchRequestDidSuccessNotification = @"WeiboShortURLManagerBatchRequestDidSuccessNotification";
NSString * const WeiboShortURLManagerNotificationShortURLSetKey = @"WeiboShortURLManagerNotificationShortURLSetKey";

@interface WeiboShortURLManager ()
{
    struct {
        unsigned int scheduledRequest: 1;
    } _flags;
}

@property (nonatomic, strong) NSCache * shortURLs;
@property (nonatomic, strong) NSMutableSet * pendingURLs;
@property (nonatomic, strong) NSMutableSet * requestingURLs;

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
        self.shortURLs = [[NSCache alloc] init];
        self.shortURLs.countLimit = 2000; // enough...
        self.pendingURLs = [NSMutableSet set];
        self.requestingURLs = [NSMutableSet set];
    }
    return self;
}

#pragma mark - 

- (WeiboExpandedURL *)expandedURLWithShortURL:(NSString *)shortURL
{
    if (!shortURL) return nil;
    return [self.shortURLs objectForKey:shortURL];
}

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

- (void)requestForURLSet:(NSSet *)urls
{
    if (!urls.count) return;
    
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    
    if (!accounts.count) return;
    
    // random account here, prevents open API access limit
    WeiboAccount * account = [accounts objectAtIndex:arc4random() % accounts.count];
    
    [[account authenticatedRequestWithCompletion:^(id responseObject) {
        [self.requestingURLs minusSet:urls];
        
        if (![responseObject isKindOfClass:[WeiboRequestError class]])
        {
            for (WeiboExpandedURL * shortURL in responseObject)
            {
                if (!shortURL.shortURL.length || !shortURL.originalURL.length) continue;
                
                [self->_shortURLs setObject:shortURL forKey:shortURL.shortURL];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WeiboShortURLManagerBatchRequestDidSuccessNotification object:self userInfo:@{WeiboShortURLManagerNotificationShortURLSetKey : urls}];
        }
    }] expandShortURLs:urls];
}

- (void)batchRequest
{
    _flags.scheduledRequest = NO;
    
    if (_pendingURLs.count)
    {
        NSMutableArray * array = [_pendingURLs.allObjects mutableCopy];
        
        [_requestingURLs addObjectsFromArray:array];
        [_pendingURLs removeAllObjects];
        
        while (array.count)
        {
            NSUInteger count = MIN((NSUInteger)20, array.count);
            NSRange range = NSMakeRange(0, count);
            
            NSSet * batch = [NSSet setWithArray:[array subarrayWithRange:range]];
            
            [self requestForURLSet:batch];
            [array removeObjectsInRange:range];
        }
        
    }
}

- (void)enqueueShortURL:(NSString *)shortURL
{
    if (!shortURL.length || [shortURL rangeOfString:@"//t.cn/"].location == NSNotFound)
    {
        return;
    }
    
    if ([_shortURLs objectForKey:shortURL]) return;
    if ([_requestingURLs containsObject:shortURL]) return;
    
    if (![_pendingURLs containsObject:shortURL])
    {
        [_pendingURLs addObject:shortURL];
        [self setNeedsRequest];
    }
}

@end
