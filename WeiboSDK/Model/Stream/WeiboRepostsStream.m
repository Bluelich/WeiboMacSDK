//
//  WeiboRepostsStream.m
//  Weibo
//
//  Created by Wutian on 13-12-19.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboRepostsStream.h"
#import "WeiboStatus.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboRepostsStream

- (void)dealloc
{
    _baseStatus = nil;
}

- (void)_loadNewer
{
    WeiboCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api repostsForStatusID:self.baseStatus.sid sinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder
{
    WeiboCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    
    // must pass in a maxID >= 0
    WeiboStatusID maxID = [self oldestStatusID];
    if (maxID > 0) {
        maxID -= 1;
    }
    [api repostsForStatusID:self.baseStatus.sid sinceID:0 maxID:maxID count:100];
}
- (BOOL)supportsFillingInGaps
{
    return NO;
}
- (id)autosaveName
{
    return [[super autosaveName] stringByAppendingFormat:@"%lld/Reposts.scrollPosition",self.baseStatus.sid];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type
{
    for (WeiboStatus * status in newStatuses)
    {
        if ([status isKindOfClass:[WeiboStatus class]])
        {
            [status setTreatRetweetedStatusAsQuoted:NO];
        }
    }
    [super addStatuses:newStatuses withType:type];
}

@end
