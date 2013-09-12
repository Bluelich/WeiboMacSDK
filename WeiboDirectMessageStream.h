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

@interface WeiboDirectMessageStream : WeiboStream <NSCoding>

@property (nonatomic, retain) NSArray * messages;
@property (nonatomic, assign) WeiboAccount * account;

- (BOOL)forceReadBit;

- (WeiboMessageID)newestMessageID;
- (WeiboMessageID)oldestMessageID;

- (void)_loadNewer;
- (void)_loadOlder;

- (void)loadNewer;
- (void)loadOlder;

- (BOOL)isLoading;
- (BOOL)isLoadingNewer;
- (BOOL)isLoadingOlder;

- (WTCallback *)loadNewerResponseCallback;
- (WTCallback *)loaderOlderResponseCallback;

- (void)addMessages:(NSArray *)messages;
- (void)deleteMessage:(WeiboDirectMessage *)message;

@end
