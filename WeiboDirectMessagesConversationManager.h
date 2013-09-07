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

@class WeiboAccount;

@interface WeiboDirectMessagesConversationManager : NSObject <NSCoding>

- (instancetype)initWithAccount:(WeiboAccount *)account;

- (void)refresh;
- (void)loadOlder;

@property (nonatomic, retain, readonly) WeiboReceivedDirectMessageStream * receivedStream;
@property (nonatomic, retain, readonly) WeiboSentDirectMessageStream *sentStream;
@property (nonatomic, retain, readonly) NSArray * conversations;
@property (nonatomic, retain, readonly) NSArray * unreadConversations;

@end
