//
//  WeiboSentDirectMessageStream.m
//  Weibo
//
//  Created by Wutian on 13-9-4.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboSentDirectMessageStream.h"
#import "WeiboAPI+DirectMessages.h"
#import "WeiboAccount+Superpower.h"

@implementation WeiboSentDirectMessageStream

- (void)_loadNewer
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self loadNewerResponseCallback]];
    
    [api sentDirectMessagesSinceID:[self newestMessageID] maxID:0 count:200];
}

- (void)_loadOlder
{
    WeiboAPI * api = [self.account authenticatedSuperpowerRequest:[self loaderOlderResponseCallback]];
    
    [api sentDirectMessagesSinceID:0 maxID:[self oldestMessageID]-1 count:200];
}

- (BOOL)messagesFromAccount
{
    return YES;
}

@end
