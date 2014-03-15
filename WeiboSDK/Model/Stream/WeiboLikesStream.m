//
//  WeiboLikesStream.m
//  Weibo
//
//  Created by Wutian on 14-3-10.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboLikesStream.h"
#import "WeiboStatus.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboAccount+Superpower.h"

@interface WeiboLikesStream ()
{
    NSInteger loadedPage;
}

@end

@implementation WeiboLikesStream


- (void)_loadNewer
{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedSuperpowerRequest:callback];
    [api likeListForStautsID:self.baseStatus.sid page:1 count:50];
}
- (void)_loadOlder
{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedSuperpowerRequest:callback];
    
    [api likeListForStautsID:self.baseStatus.sid page:loadedPage+1 count:50];
}
- (BOOL)supportsFillingInGaps
{
    return NO;
}
- (id)autosaveName
{
    return [[super autosaveName] stringByAppendingFormat:@"%lld/Likes.scrollPosition",self.baseStatus.sid];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type{
    if ((!self.hasData && type == WeiboStatusesAddingTypePrepend) ||
        type == WeiboStatusesAddingTypeAppend)
    {
        loadedPage++;
    }
    [super addStatuses:newStatuses withType:type];
}

@end
