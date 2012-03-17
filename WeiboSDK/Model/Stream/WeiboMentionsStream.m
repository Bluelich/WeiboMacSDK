//
//  WeiboMentionsStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-22.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboMentionsStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI.h"

@implementation WeiboMentionsStream

- (BOOL)shouldIndexUsersInAutocomplete{
    return YES;
}
- (void)_loadNewer{
    WTCallback * callback = [self loadNewerResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api mentionsSinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20];
}
- (void)_loadOlder{
    WTCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api mentionsSinceID:0 maxID:[self oldestStatusID]-1 count:100];
}
- (NSUInteger)minStatusesToConsiderBeingGap{
    return NSUIntegerMax;
}
- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"mentions.scrollPosition"];
}
@end
