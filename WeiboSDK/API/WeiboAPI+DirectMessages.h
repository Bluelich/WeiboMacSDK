//
//  WeiboAPI+DirectMessages.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"
#import "WeiboDirectMessage.h"

@interface WeiboAPI (DirectMessages)

#pragma mark -
#pragma mark Direct Message
- (void)directMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count;
- (void)sentDirectMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count;
- (void)publicMessagesSinceID:(WeiboMessageID)since maxID:(WeiboMessageID)max count:(NSUInteger)count;

- (void)conversationsWithCount:(NSInteger)count cursor:(WeiboUserID)cursor; // implemented by a user_list REST API, so cursor should be a userID
- (void)directMessagesWithUserID:(WeiboUserID)userID since:(WeiboMessageID)sinceID max:(WeiboMessageID)maxID count:(NSUInteger)count;

- (void)sendDirectMessage:(NSString *)text toUserID:(WeiboUserID)userID;

@end
