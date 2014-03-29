//
//  WeiboDirectMessageConversation.h
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboDirectMessage.h"

extern NSString * const WeiboDirectMessageConversationDidUpdateNotification;
extern NSString * const WeiboDirectMessageConversationDidMarkAsReadNotification;

@interface WeiboDirectMessageConversation : WeiboModel <NSCoding>

- (WeiboDirectMessage *)newestMessageNotFrom:(WeiboUser *)user;
- (void)beginAddingMessages;
- (void)addMessage:(WeiboDirectMessage *)message;
- (void)endAddingMessages;

- (void)deleteMessage:(WeiboDirectMessage *)message;
- (BOOL)isRepliedTo;
- (BOOL)hasUnreadMessages;
- (void)markAsRead;

- (NSComparisonResult)compare:(WeiboDirectMessageConversation *)other;

@property (nonatomic, strong, readonly) NSArray * messages;
@property (nonatomic, strong, readonly) WeiboDirectMessage * mostRecentMessage;
@property (nonatomic, strong) WeiboUser * correspondent;

@end
