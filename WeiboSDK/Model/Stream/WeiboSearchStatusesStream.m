//
//  WeiboSearchStatusesStream.m
//  Weibo
//
//  Created by Wutian on 13-10-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboSearchStatusesStream.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboAccount+Superpower.h"

@implementation WeiboSearchStatusesStream

- (void)dealloc
{
    _keyword = nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        NSString * keyword = [aDecoder decodeObjectForKey:@"keyword"];
        self.keyword = keyword;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.keyword forKey:@"keyword"];
}

- (void)_loadNewer
{
    WeiboAPI * api = [account authenticatedSuperpowerRequest:[self loadNewerResponseCallback]];
    
    WeiboBaseStatus * status = [self newestStatus];
    
    [api statusesWithKeyword:self.keyword startTime:(status.createdAt + 1) endTime:0 count:50];
}
- (void)_loadOlder
{
    WeiboAPI * api = [account authenticatedSuperpowerRequest:[self loadOlderResponseCallback]];
    
    WeiboBaseStatus * status = [self oldestStatus];
    
    [api statusesWithKeyword:self.keyword startTime:0 endTime:MAX(0, (status.createdAt - 1)) count:50];
}

- (BOOL)supportsFillingInGaps
{
    return NO;
}
- (id)autosaveName
{
    return [[super autosaveName] stringByAppendingFormat:@"search/statuses/%@.scrollPosition",self.keyword];
}

@end
