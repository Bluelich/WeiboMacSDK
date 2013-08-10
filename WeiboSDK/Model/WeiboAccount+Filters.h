//
//  WeiboAccount+Filters.h
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"
#import "WeiboStatusFilter.h"
#import "WeiboStatusKeywordFilter.h"
#import "WeiboStatusSourceFilter.h"
#import "WeiboStatusUserFilter.h"
#import "WeiboStatusUserHighlighter.h"

extern NSString * const WeiboAccountFilterSetDidChangeNotification;

@interface WeiboAccount (Filters)

@property (nonatomic, readonly) NSArray * allFilters;

- (void)addFilterWithKeyword:(NSString *)keyword effectiveTime:(NSTimeInterval)time;
- (void)addFilterWithUser:(WeiboUser *)user effectiveTime:(NSTimeInterval)time;
- (void)addFilterWithClientName:(NSString *)source effectiveTime:(NSTimeInterval)time;
- (void)addHighlighterWithUser:(WeiboUser *)user effectiveTime:(NSTimeInterval)time;

- (void)removeFilter:(WeiboStatusFilter *)filter;

- (void)pruneFilters;

@end
