//
//  WeiboAccount+Lists.m
//  Weibo
//
//  Created by Wutian on 13-7-28.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Lists.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboList.h"
#import "WTCallback.h"

NSString * const WeiboAccountListsDidUpdateNotification = @"WeiboAccountListsDidUpdateNotification";

@implementation WeiboAccount (Lists)

- (void)updateLists
{
    if ([self isLoadingLists])
    {
        return;
    }
    
    _flags.listsAccessDenied = NO;
    
    WTCallback * callback = WTCallbackMake(self, @selector(listsResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api lists];
}

- (void)listsResponse:(id)response info:(id)info
{
    BOOL postsNotification = NO;
    
    if ([response isKindOfClass:[NSArray class]])
    {
        postsNotification = YES;
        
        _flags.listsLoaded = YES;
        
        [_lists removeAllObjects];
        [_lists addObjectsFromArray:response];
        
        {
            // Add Special Lists
            WeiboList * friendCircleList = [WeiboList new];
            
            friendCircleList.listID = WeiboDummyListIDFirendCircle;
            friendCircleList.name = @"好友圈";
            friendCircleList.description = @"最新好友动态";
            friendCircleList.memberCount = NSNotFound;
            
            [_lists insertObject:friendCircleList atIndex:0];
        }
        
        [_lists makeObjectsPerformSelector:@selector(setAccount:) withObject:self];
    }
    else if ([response isKindOfClass:[WeiboRequestError class]])
    {
        WeiboRequestError * error = response;
        if (error.code == WeiboErrorCodeScopeAccessDenied)
        {
            postsNotification = YES;
            _flags.listsAccessDenied = YES;
        }
    }
    
    if (postsNotification)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountListsDidUpdateNotification object:self userInfo:nil];
    }
}

- (BOOL)isLoadingLists
{
    return _flags.loadingLists;
}
- (BOOL)listsLoaded
{
    return _flags.listsLoaded;
}
- (BOOL)listsAccessDenied
{
    return _flags.listsAccessDenied;
}
- (NSArray *)lists
{
    if (!_lists)
    {
        _lists = [[NSMutableArray alloc] init];
    }
    return _lists;
}

@end
