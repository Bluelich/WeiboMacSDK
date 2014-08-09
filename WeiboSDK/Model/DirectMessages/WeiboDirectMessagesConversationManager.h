//
//  WeiboDirectMessagesConversationManager.h
//  Weibo
//
//  Created by Wutian on 13-9-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboReceivedDirectMessageStream.h"
#import "WeiboSentDirectMessageStream.h"

extern NSString * const WeiboDirectMessagesConversationListDidUpdateNotification;
extern NSString * const WeiboDirectMessagesManagerDidFinishLoadingNotification;

@class WeiboAccount;

@interface WeiboDirectMessagesConversationManager : NSObject <NSCoding>

- (instancetype)initWithAccount:(WeiboAccount *)account;

- (void)initialzeConversationsIfNeeded;

- (void)refresh;
- (void)loadOlder;

@property (nonatomic, strong, readonly) NSArray * messageStreams; // messageStream objects managed by this object
@property (nonatomic, strong, readonly) NSArray * conversations;
@property (nonatomic, strong, readonly) NSArray * unreadConversations;

- (void)markConversationWithUserIDAsRead:(WeiboUserID)userID;

@property (nonatomic, assign, readonly) BOOL isLoadingNewer;
@property (nonatomic, assign, readonly) BOOL isLoadingOlder;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)requestStreaming; // poll间隔提到15秒一次
- (void)endStreaming;

@end
