//
//  WeiboUserUserList.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserList.h"
#import "WeiboUser.h"
#import "WeiboAccount.h"

extern NSString * const WeiboUserUserListDidAddUsersNotification;
extern NSString * const WeiboUserUserListDidReceiveRequestErrorNotification;

extern NSString * const WeiboUserUserListDidAddUserNotificationUsersKey;
extern NSString * const WeiboUserUserListDidAddUserNotificationPrependKey;
extern NSString * const WeiboUserUserListNotificationRequestErrorKey;

@interface WeiboUserUserList : WeiboUserList

@property (nonatomic, assign, readonly) WeiboUserID cursor;
@property (nonatomic, strong) WeiboUser * user;
@property (nonatomic, strong) WeiboAccount * account;

- (void)markAtEnd;
- (BOOL)isEnded;

- (void)didAddUsers:(NSArray *)users prepend:(BOOL)prepend;

- (WeiboCallback *)usersListCallbackWithLoadingNewer:(BOOL)loadingNewer;

@end
