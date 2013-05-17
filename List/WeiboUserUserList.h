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

@interface WeiboUserUserList : WeiboUserList

@property (nonatomic, retain, readonly) NSString * cursor;
@property (nonatomic, retain) WeiboUser * user;
@property (nonatomic, retain) WeiboAccount * account;

- (void)markAtEnd;
- (void)didAddUsers:(NSArray *)users;

- (WTCallback *)receiveUsersCallback;

@end
