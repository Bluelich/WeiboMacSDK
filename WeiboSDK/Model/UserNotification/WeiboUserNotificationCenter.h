//
//  WeiboUserNotificationCenter.h
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboAccount;

@interface WeiboUserNotificationCenter : NSObject

+ (instancetype)defaultUserNotificationCenter;

// call this when your appDelegate's applicationDidFinishLaunching: get called
- (void)applicationLaunchingFinishedWithNotification:(NSNotification *)notification;

- (void)scheduleNotificationForMentions:(NSArray *)mentions forAccount:(WeiboAccount *)account;
- (void)scheduleNotificationForComments:(NSArray *)comments forAccount:(WeiboAccount *)account;
- (void)scheduleNotificationForDirectMessages:(NSArray *)messages forAccount:(WeiboAccount *)account;

@end
