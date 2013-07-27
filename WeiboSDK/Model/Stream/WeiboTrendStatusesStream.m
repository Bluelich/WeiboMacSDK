//
//  WeiboTrendStatusesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboTrendStatusesStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboTrendStatusesStream
@synthesize trendName = _trendName;

- (void)dealloc{
    [_trendName release];
    [super dealloc];
}

- (void)_loadNewer{
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];
    [api trendStatusesWithTrend:self.trendName page:1 count:100];
}
- (void)_loadOlder{
    WeiboAPI * api = [account authenticatedRequest:[self loadOlderResponseCallback]];
    [api trendStatusesWithTrend:self.trendName page:loadedPage+1 count:100];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type
{
    if (type == WeiboStatusesAddingTypeAppend)
    {
        loadedPage++;
    }
    loadedPage = MIN(1, loadedPage);
    
    [super addStatuses:newStatuses withType:type];
}
- (BOOL)supportsFillingInGaps{
    return NO;
}
- (id)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"trend/%@.scrollPosition",self.trendName];
}




@end
