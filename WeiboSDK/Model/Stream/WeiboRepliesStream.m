//
//  WeiboRepliesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboRepliesStream.h"
#import "WeiboAccount.h"
#import "WeiboStatus.h"
#import "WeiboAPI.h"

@implementation WeiboRepliesStream
@synthesize baseStatus;

- (void)dealloc{
    self.baseStatus = nil;
    [super dealloc];
}

- (void)_loadNewer{
    // This should not be called
}
- (void)_loadOlder{
    WeiboAPI * api = [account authenticatedRequest:[self loadOlderResponseCallback]];
    [api repliesForStatusID:baseStatus.sid page:loadedPage+1 count:[self hasData]?100:20];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type{
    loadedPage++;
    [super addStatuses:newStatuses withType:type];
}
- (BOOL)canLoadNewer{
    return NO;
}
- (BOOL)supportsFillingInGaps{
    return NO;
}
- (id)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"%lld/Replies.scrollPosition",baseStatus.sid];
}

@end
