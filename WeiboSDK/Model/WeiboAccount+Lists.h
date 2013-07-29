//
//  WeiboAccount+Lists.h
//  Weibo
//
//  Created by Wutian on 13-7-28.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"

extern NSString * const WeiboAccountListsDidUpdateNotification;

@interface WeiboAccount (Lists)

- (void)updateLists;
- (BOOL)isLoadingLists;
- (BOOL)listsLoaded;
- (BOOL)listsAccessDenied;
- (NSArray *)lists;

@end
