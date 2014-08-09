//
//  WeiboStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStream.h"

@implementation WeiboStream
@synthesize cacheTime, statuses, savedCellIndex, savedRelativeOffset;
@synthesize viewedMostRecentID = _viewedMostRecentID;

- (id)initWithCoder:(NSCoder * __attribute__((unused)))aDecoder
{
    if (self = [self init])
    {
        
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder * __attribute__((unused)))aCoder
{
    
}

- (BOOL)canLoadNewer{
    return YES;
}

- (void)loadNewer{
    // subclass should implement
}
- (void)loadOlder{
    // subclass should implement
}
- (void)retryLoadOlder{
    
}
- (void)fillInGap:(id __attribute__((unused)))arg1
{
    // subclass should implement
}
- (BOOL)supportsFillingInGaps{
    return NO;
}
- (BOOL)hasData{
    return [[self statuses] count] > 0;
}
- (void)didLoadOlder{
    // subclass should implement
}
- (NSString *)autosaveName{
    return nil;
}
- (NSUInteger)statuseIndexByID:(WeiboStatusID __attribute__((unused)))theID{
    return 0;
}
- (BOOL)isStreamEnded{
    return NO;
}

- (NSString *)viewedMostRecentIDKey
{
    NSString * autosaveName = [self autosaveName];
    return [autosaveName stringByAppendingString:@"/viewedMostRecentID"];
}
- (void)setViewedMostRecentID:(WeiboStatusID)viewedMostRecentID
{
    _viewedMostRecentID = viewedMostRecentID;
    NSString * key = [self viewedMostRecentIDKey];
    if (key)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(viewedMostRecentID) forKey:key];
    }
}
- (WeiboStatusID)viewedMostRecentID
{
    if (_viewedMostRecentID == 0)
    {
        NSString * key = [self viewedMostRecentIDKey];
        if (key)
        {
            NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
            _viewedMostRecentID = [[ud objectForKey:key] unsignedLongLongValue];
        }
    }
    return _viewedMostRecentID;
}

@end
