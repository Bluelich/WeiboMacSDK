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
#import "WeiboPrivateMessagesConversationManager.h"
#import "WeiboDirectMessageConversation.h"

@interface WeiboPublicMessagesConversationManager ()

@property (nonatomic, strong) WeiboPublicDirectMessageStream * publicMessageStream;

@end

@implementation WeiboPublicMessagesConversationManager

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compositionDidSent:) name:WeiboAccountDidSentCompositionNotification object:nil];
    }
    return self;
}

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

- (void)compositionDidSent:(NSNotification *)notification
{
    if (notification.object != self.account) {
        return;
    }
    
    id<WeiboComposition> compostion = notification.userInfo[WeiboAccountDidSentCompositionNotificationCompositionKey];
    
    if (!compostion || compostion.type != WeiboCompositionTypeDirectMessage) {
        return;
    }
    
    WeiboUser * user = compostion.directMessageUser;
    
    if (!user) {
        return;
    }
    
    WeiboDirectMessageConversation * conversation = [self conversationWithUserID:user.userID];
    
    if (!conversation) {
        return;
    }
    
    [self.account.privateMessagesManager.receivedStream addMessages:conversation.messages fromServer:NO];
    [self deleteConversation:conversation];
}

@end
