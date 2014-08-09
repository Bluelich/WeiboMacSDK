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
    WeiboAPI * api = [account authenticatedSuperpowerRequest:callback];
    [api likeListForStautsID:self.baseStatus.sid page:1 count:50];
}
- (void)_loadOlder
{
    WeiboCallback * callback = [self loadOlderResponseCallback];
    WeiboAPI * api = [account authenticatedSuperpowerRequest:callback];
    
    [api likeListForStautsID:self.baseStatus.sid page:(NSUInteger)(loadedPage+1) count:50];
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
