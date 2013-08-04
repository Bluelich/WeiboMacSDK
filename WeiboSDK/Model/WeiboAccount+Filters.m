//
//  WeiboAccount+Filters.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Filters.h"
#import "WeiboUser.h"

NSString * const WeiboAccountFilterSetDidChangeNotification = @"WeiboAccountFilterSetDidChangeNotification";

@implementation WeiboAccount (Filters)

- (NSArray *)allFilters
{
    NSMutableArray * array = [NSMutableArray array];
    
    [array addObjectsFromArray:self.keywordFilters];
    [array addObjectsFromArray:self.userFilters];
    [array addObjectsFromArray:self.userHighlighters];
    [array addObjectsFromArray:self.clientFilters];
    
    return array;
}

- (void)filterSetDidChange;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountFilterSetDidChangeNotification object:self];
}

- (void)_addFilter:(WeiboStatusFilter *)filter toArray:(NSMutableArray *)array withEffectiveTime:(NSTimeInterval)time
{
    filter.createTime = [NSDate timeIntervalSinceReferenceDate];
    filter.expireTime = filter.createTime + time;
    
    [array addObject:filter];
}

- (void)addFilterWithKeyword:(NSString *)keyword effectiveTime:(NSTimeInterval)time
{
    if (!keyword.length) return;
    
    WeiboStatusKeywordFilter * filter = [WeiboStatusKeywordFilter new];
    [filter setKeyword:keyword];
    [self _addFilter:filter toArray:self.keywordFilters withEffectiveTime:time];
    [filter release];
    
    [self filterSetDidChange];
}
- (void)addFilterWithUser:(WeiboUser *)user_ effectiveTime:(NSTimeInterval)time
{
    if (!user_.screenName || !user_.userID) return;
    
    WeiboStatusUserFilter * filter = [WeiboStatusUserFilter new];
    [filter setUserID:user_.userID];
    [filter setScreenname:user_.screenName];
    [self _addFilter:filter toArray:self.userFilters withEffectiveTime:time];
    [filter release];
    
    [self filterSetDidChange];
}
- (void)addFilterWithClientName:(NSString *)source effectiveTime:(NSTimeInterval)time
{
    if (!source) return;
    
    WeiboStatusSourceFilter * filter = [WeiboStatusSourceFilter new];
    [filter setSource:source];
    [self _addFilter:filter toArray:self.clientFilters withEffectiveTime:time];
    [filter release];
    
    [self filterSetDidChange];
}
- (void)addHighlighterWithUser:(WeiboUser *)user_ effectiveTime:(NSTimeInterval)time
{
    if (!user_.screenName || !user_.userID) return;
    
    WeiboStatusUserHighlighter * filter = [WeiboStatusUserHighlighter new];
    [filter setUserID:user_.userID];
    [filter setScreenname:user_.screenName];
    [self _addFilter:filter toArray:self.userHighlighters withEffectiveTime:time];
    [filter release];
    
    [self filterSetDidChange];
}

- (void)removeFilter:(WeiboStatusFilter *)filter
{
    if (!filter) return;
    
    [self.keywordFilters removeObject:filter];
    [self.clientFilters removeObject:filter];
    [self.userHighlighters removeObject:filter];
    [self.userFilters removeObject:filter];
    
    [self filterSetDidChange];
}

- (void)purgeFilters
{
    
}

@end
