//
//  WeiboDirectMessageStream.h
//  Weibo
//
//  Created by Wutian on 13-9-4.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStream.h"
#import "WeiboDirectMessage.h"

extern NSString * const WeiboDirectMessageStreamDidUpdateNotification;
extern NSString * const WeiboDirectMessageStreamFinishedLoadingNotification;

@class WeiboAccount;

@interface WeiboDirectMessageStream : WeiboStream

@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, weak) WeiboAccount * account;

@property (nonatomic, assign, readonly) BOOL messagesFromAccount;

- (WeiboMessageID)newestMessageID;
- (WeiboMessageID)oldestMessageID;

- (void)_loadNewer;
- (void)_loadOlder;

- (void)loadNewer;
- (void)loadOlder;

- (BOOL)isLoading;
- (BOOL)isLoadingNewer;
- (BOOL)isLoadingOlder;

- (BOOL)messagesLoaded;

- (WeiboCallback *)loadNewerResponseCallback;
- (WeiboCallback *)loaderOlderResponseCallback;

- (void)addMessages:(NSArray *)messages;
- (void)deleteMessage:(WeiboDirectMessage *)message;

@end
