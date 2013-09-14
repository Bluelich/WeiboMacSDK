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

@interface WeiboDirectMessageConversation : NSObject <NSCoding>

- (WeiboDirectMessage *)newestMessageNotFrom:(WeiboUser *)user;
- (void)beginAddingMessages;
- (void)addMessage:(WeiboDirectMessage *)message;
- (void)endAddingMessages;

- (void)deleteMessage:(WeiboDirectMessage *)message;
- (BOOL)isRepliedTo;
- (BOOL)hasUnreadMessages;
- (void)markAsRead;

- (NSComparisonResult)compare:(WeiboDirectMessageConversation *)other;

@property (nonatomic, retain, readonly) NSArray * messages;
@property (nonatomic, retain, readonly) WeiboDirectMessage * mostRecentMessage;
@property (nonatomic, retain) WeiboUser * correspondent;

@end
