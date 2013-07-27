//
//  WeiboAccount+Lists.m
//  Weibo
//
//  Created by Wutian on 13-7-28.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Lists.h"
#import "WeiboAPI+StatusMethods.h"
#import "WTCallback.h"

NSString * const WeiboAccountListsDidUpdateNotification = @"WeiboAccountListsDidUpdateNotification";

@implementation WeiboAccount (Lists)

- (void)updateLists
{
    if ([self isLoadingLists])
    {
        return;
    }
    
    WTCallback * callback = WTCallbackMake(self, @selector(listsResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api lists];
}

- (void)listsResponse:(id)response info:(id)info
{
    if (![response isKindOfClass:[NSArray class]]) {
        return;
    }

    [_lists removeAllObjects];
    [_lists addObjectsFromArray:response];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountListsDidUpdateNotification object:self userInfo:nil];
}

- (BOOL)isLoadingLists
{
    return _flags.loadingLists;
}
- (NSArray *)lists
{
    return _lists;
}

@end
