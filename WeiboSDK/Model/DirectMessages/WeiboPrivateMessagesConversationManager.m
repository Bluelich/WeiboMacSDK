//
//  WeiboPrivateMessagesConversationManager.m
//  Weibo
//
//  Created by Wutian on 14/8/9.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboPrivateMessagesConversationManager.h"
#import "WeiboDirectMessagesConversationManager_Private.h"

@interface WeiboPrivateMessagesConversationManager ()

@property (nonatomic, strong) WeiboSentDirectMessageStream * sentStream;
@property (nonatomic, strong) WeiboReceivedDirectMessageStream * receivedStream;

@end

@implementation WeiboPrivateMessagesConversationManager

- (void)setAccount:(WeiboAccount *)account
{
    if (account != self.account) {
        [super setAccount:account];
        
        self.sentStream = [[WeiboSentDirectMessageStream alloc] init];
        self.receivedStream = [[WeiboReceivedDirectMessageStream alloc] init];
        
        self.sentStream.account = account;
        self.receivedStream.account = account;
    }
}

- (NSArray *)messageStreams
{
    if (!_sentStream || !_receivedStream) {
        return nil;
    }
    return @[_sentStream, _receivedStream];
}

@end
