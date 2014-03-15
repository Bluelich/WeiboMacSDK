//
//  WeiboAccount+DirectMessage.h
//  Weibo
//
//  Created by Wutian on 13-9-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"
#import "WeiboDirectMessagesConversationManager.h"

@interface WeiboAccount (DirectMessage)

- (void)saveDirectMessages;
- (WeiboDirectMessagesConversationManager *)restoreDirectMessageManager;

@end
