//
//  WeiboPrivateMessagesConversationManager.h
//  Weibo
//
//  Created by Wutian on 14/8/9.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboDirectMessagesConversationManager.h"

@interface WeiboPrivateMessagesConversationManager : WeiboDirectMessagesConversationManager

@property (nonatomic, strong, readonly) WeiboDirectMessageStream * receivedStream;
@property (nonatomic, strong, readonly) WeiboDirectMessageStream * sentStream;

@end
