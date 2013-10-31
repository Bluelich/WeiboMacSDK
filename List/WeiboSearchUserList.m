//
//  WeiboSearchUserList.m
//  Weibo
//
//  Created by Wutian on 13-10-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboSearchUserList.h"
#import "WeiboAccount+Superpower.h"
#import "WeiboAPI+UserMethods.h"

@interface WeiboSearchUserList ()

@property (nonatomic, assign) NSInteger loadedPage;

@end

@implementation WeiboSearchUserList

- (void)dealloc
{
    [_keyword release], _keyword = nil;
    [super dealloc];
}

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self usersListCallbackWithLoadingNewer:YES]];
    [api usersWithKeyword:self.keyword page:0];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self usersListCallbackWithLoadingNewer:NO]];
    [api usersWithKeyword:self.keyword page:self.loadedPage + 1];
}

- (void)didAddUsers:(NSArray *)users prepend:(BOOL)prepend
{
    if (!prepend)
    {
        self.loadedPage++;
    }
    self.loadedPage = MAX(1, self.loadedPage);
    
    [super didAddUsers:users prepend:prepend];
}

@end
