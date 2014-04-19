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
#import "WeiboComment.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboRepliesStream
@synthesize baseStatus;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        WeiboStatus * status = [aDecoder decodeObjectForKey:@"base-status"];
        
        if (![status isKindOfClass:[WeiboStatus class]]) return nil;
        
        self.baseStatus = status;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.baseStatus forKey:@"base-status"];
}

- (void)_loadNewer
{
    WeiboCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api repliesForStatusID:baseStatus.sid sinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
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
    [api repliesForStatusID:baseStatus.sid sinceID:0 maxID:maxID count:100];
}
- (BOOL)supportsFillingInGaps
{
    return NO;
}
- (id)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"%lld/Replies.scrollPosition",baseStatus.sid];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type
{
    for (WeiboComment * comment in newStatuses)
    {
        if ([comment isKindOfClass:[WeiboComment class]])
        {
            [comment setTreatReplyingStatusAsQuoted:NO];
        }
    }
    [super addStatuses:newStatuses withType:type];
}


@end
