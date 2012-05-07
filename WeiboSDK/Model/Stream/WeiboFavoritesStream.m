//
//  WeiboFavoritesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-5-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboFavoritesStream.h"
#import "WeiboAccount.h"
#import "WeiboAPI.h"

@implementation WeiboFavoritesStream

- (void)_loadNewer{
    // This should not be called
}
- (void)loadNewer{
    [self loadOlder];
}
- (void)_loadOlder{
    WeiboAPI * api = [account authenticatedRequest:[self loadOlderResponseCallback]];
    [api favoritesForPage:loadedPage+1 count:[self hasData]?100:20];
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
    return [[super autosaveName] stringByAppendingString:@"favorites.scrollPosition"];
}

@end
