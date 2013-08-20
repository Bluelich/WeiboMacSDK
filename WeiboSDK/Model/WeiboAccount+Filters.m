//
//  WeiboAccount+Filters.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+Filters.h"
#import "WeiboUser.h"
#import "WeiboStatusAccountMentionFilter.h"

NSString * const WeiboAccountFilterSetDidChangeNotification = @"WeiboAccountFilterSetDidChangeNotification";

@implementation WeiboAccount (Filters)

- (NSArray *)allFilters
{
    NSMutableArray * array = [NSMutableArray array];
    
    [array addObjectsFromArray:self.keywordFilters];
    [array addObjectsFromArray:self.userFilters];
    [array addObjectsFromArray:self.userHighlighters];
    [array addObjectsFromArray:self.clientFilters];
    
    if (!self.mentionHighlighter)
    {
        self.mentionHighlighter = [[WeiboStatusAccountMentionFilter new] autorelease];
        self.mentionHighlighter.account = self;
    }
    
    [array addObject:self.mentionHighlighter];
    
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

- (WeiboStatusUserFilter *)filterForUser:(WeiboUser *)user_
{
    for (WeiboStatusUserFilter * filter in self.userFilters)
    {
        if (filter.userID == user_.userID)
        {
            return filter;
        }
    }
    return nil;
}
- (WeiboStatusUserHighlighter *)highlighterForUser:(WeiboUser *)user_
{
    for (WeiboStatusUserHighlighter * filter in self.userHighlighters)
    {
        if (filter.userID == user_.userID)
        {
            return filter;
        }
    }
    return nil;
}
- (BOOL)containsFilterForUser:(WeiboUser *)user_
{
    return ([self filterForUser:user_] != nil);
}
- (BOOL)containsHighlighterForUser:(WeiboUser *)user_
{
    return ([self highlighterForUser:user_] != nil);
}

- (void)removeFilter:(WeiboStatusFilter *)filter
{
    if (!filter) return;
    
    [filter retain];
    
    [self.keywordFilters removeObject:filter];
    [self.clientFilters removeObject:filter];
    [self.userHighlighters removeObject:filter];
    [self.userFilters removeObject:filter];
    
    [filter release];
    
    [self filterSetDidChange];
}

- (BOOL)_pruneFiltersWithMutableArray:(NSMutableArray *)array
{
    NSMutableArray * toRemove = [NSMutableArray array];
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    for (WeiboStatusFilter * filter in array)
    {
        if (filter.duration <= 0)
        {
            continue;
        }
        
        if (now > filter.expireTime)
        {
            [toRemove addObject:filter];
        }
    }
    
    [array removeObjectsInArray:toRemove];
    
    return toRemove.count > 0;
}

- (void)pruneFilters
{
    BOOL pruned = NO;
    pruned |= [self _pruneFiltersWithMutableArray:self.keywordFilters];
    pruned |= [self _pruneFiltersWithMutableArray:self.userFilters];
    pruned |= [self _pruneFiltersWithMutableArray:self.userHighlighters];
    pruned |= [self _pruneFiltersWithMutableArray:self.clientFilters];
    
    if (pruned)
    {
        [self filterSetDidChange];
    }
}

@end
