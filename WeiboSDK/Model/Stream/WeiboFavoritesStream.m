//
//  WeiboFavoritesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-5-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboFavoritesStream.h"
#import "WeiboAccount.h"
#import "WeiboStatus.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboFavoritesStream

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WeiboStatusFavoriteStateDidChangeNotifiaction object:nil];
    
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteStateDidChangeNotification:) name:WeiboStatusFavoriteStateDidChangeNotifiaction object:nil];
    }
    return self;
}

- (void)favoriteStateDidChangeNotification:(NSNotification *)notification
{
    WeiboAccount * theAccount = notification.object;
    WeiboStatus * status = notification.userInfo[@"status"];
    
    if (!theAccount || !status) return;
    if (theAccount != account) return;
    
    NSInteger idx = [self.statuses indexOfObject:status];
    
    if (status.favorited)
    {
        [self.statuses removeObject:status];
        [self.statuses insertObject:status atIndex:0];
        
        if (idx != NSNotFound)
        {
            [self postStatusesChangedNotification];
        }
        else
        {
            [self noticeDidReceiveNewStatuses:@[status] withAddingType:WeiboStatusesAddingTypePrepend];
        }
    }
    else
    {
        if (idx != NSNotFound)
        {
            [self.statuses removeObjectAtIndex:idx];
        }
        [self noticeDidRemoveStatus:status atIndex:idx];
    }
}

- (void)_loadNewer{
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];
    [api favoritesForPage:1 count:50];
}
- (void)_loadOlder{
    WeiboAPI * api = [account authenticatedRequest:[self loadOlderResponseCallback]];
    [api favoritesForPage:loadedPage+1 count:50];
}

- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type{
    if ((!self.hasData && type == WeiboStatusesAddingTypePrepend) ||
        type == WeiboStatusesAddingTypeAppend)
    {
        loadedPage++;
    }
    [super addStatuses:newStatuses withType:type];
}
- (BOOL)supportsFillingInGaps{
    return NO;
}
- (id)autosaveName{
    return [[super autosaveName] stringByAppendingString:@"favorites.scrollPosition"];
}

@end
