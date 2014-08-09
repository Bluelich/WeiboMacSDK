//
//  WeiboPublicMessagesConversationManager.m
//  Weibo
//
//  Created by Wutian on 14/8/9.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboPublicMessagesConversationManager.h"
#import "WeiboDirectMessagesConversationManager_Private.h"
#import "WeiboPublicDirectMessageStream.h"

@interface WeiboPublicMessagesConversationManager ()

@property (nonatomic, strong) WeiboPublicDirectMessageStream * publicMessageStream;

@end

@implementation WeiboPublicMessagesConversationManager

- (void)setAccount:(WeiboAccount *)account
{
    if (self.account != account) {
        [super setAccount:account];
        
        self.publicMessageStream = [[WeiboPublicDirectMessageStream alloc] init];
        self.publicMessageStream.account = account;
    }
}

- (NSArray *)messageStreams
{
    if (!_publicMessageStream) {
        return nil;
    }
    return @[_publicMessageStream];
}

@end
