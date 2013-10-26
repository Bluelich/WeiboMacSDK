//
//  WeiboUserNotificationCenter.h
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboAccount;

typedef NS_ENUM(NSInteger, WeiboUserNotificationItemType)
{
    WeiboUserNotificationItemTypeMention,
    WeiboUserNotificationItemTypeComment,
    WeiboUserNotificationItemTypeDirectMessage,
    
    WeiboUserNotificationItemTypeMentions,
    WeiboUserNotificationItemTypeComments,
    WeiboUserNotificationItemTypeDirectMessages,
};

extern NSString * const WeiboUserNotificationUserInfoItemTypeKey;
extern NSString * const WeiboUserNotificationUserInfoItemUserIDKey;
extern NSString * const WeiboUserNotificationUserInfoItemIDKey;
extern NSString * const WeiboUserNotificationUserInfoAccountUserIDKey;

@interface WeiboUserNotificationCenter : NSObject

+ (instancetype)defaultUserNotificationCenter;

// call this when your appDelegate's applicationDidFinishLaunching: get called
- (void)applicationLaunchingFinishedWithNotification:(NSNotification *)notification;

- (void)scheduleNotificationForMentions:(NSArray *)mentions forAccount:(WeiboAccount *)account;
- (void)scheduleNotificationForComments:(NSArray *)comments forAccount:(WeiboAccount *)account;
- (void)scheduleNotificationForDirectMessages:(NSArray *)messages forAccount:(WeiboAccount *)account;

@end
