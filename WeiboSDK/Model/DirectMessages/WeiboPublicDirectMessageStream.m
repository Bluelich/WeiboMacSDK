//
//  WeiboPublicDirectMessageStream.m
//  Weibo
//
//  Created by Wutian on 14/8/9.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboPublicDirectMessageStream.h"
#import "WeiboAPI+DirectMessages.h"
#import "WeiboAccount+Superpower.h"

@implementation WeiboPublicDirectMessageStream

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self loadNewerResponseCallback]];
    
    [api publicMessagesSinceID:[self newestMessageID] maxID:0 count:200];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self loaderOlderResponseCallback]];
    
    [api publicMessagesSinceID:0 maxID:[self oldestMessageID]-1 count:200];
}

@end
