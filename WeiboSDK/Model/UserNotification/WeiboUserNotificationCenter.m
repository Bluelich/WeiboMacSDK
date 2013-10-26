//
//  WeiboUserNotificationCenter.m
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserNotificationCenter.h"
#import "WeiboAccount.h"
#import "WeiboBaseStatus.h"
#import "WeiboDirectMessage.h"

NSString * const WeiboUserNotificationUserInfoItemTypeKey = @"WeiboUserNotificationUserInfoItemTypeKey";
NSString * const WeiboUserNotificationUserInfoItemUserIDKey = @"WeiboUserNotificationUserInfoItemUserIDKey";
NSString * const WeiboUserNotificationUserInfoItemIDKey = @"WeiboUserNotificationUserInfoItemIDKey";
NSString * const WeiboUserNotificationUserInfoAccountUserIDKey = @"WeiboUserNotificationUserInfoAccountUserIDKey";

@interface WeiboUserNotificationCenter () <NSUserNotificationCenterDelegate>

@property (nonatomic, assign, readonly) BOOL supportsDirectlyReply;

@end

@implementation WeiboUserNotificationCenter

static BOOL AtLeastMountainLion = NO;

+ (void)initialize
{
    SInt32 major = 0;
    SInt32 minor = 0;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    AtLeastMountainLion = (major == 10 && minor >= 8);
}

+ (instancetype)defaultUserNotificationCenter
{
    if (!AtLeastMountainLion) return nil;
    
    static WeiboUserNotificationCenter * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:instance];
    });
    return instance;
}

- (void)applicationLaunchingFinishedWithNotification:(NSNotification *)notification
{
    if (!AtLeastMountainLion) return;
    
    NSDictionary * userInfo = notification.userInfo;
    
    NSUserNotification * userNotification = userInfo[NSApplicationLaunchUserNotificationKey];
    
    if (userNotification)
    {
        [self userNotificationCenter:[NSUserNotificationCenter defaultUserNotificationCenter] didActivateNotification:userNotification];
    }
}

- (BOOL)supportsDirectlyReply
{
    return [NSUserNotification instancesRespondToSelector:@selector(setHasReplyButton:)];
}

- (void)_scheduleUserNotification:(NSUserNotification *)notification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

- (void)scheduleNotificationForMentions:(NSArray *)mentions forAccount:(WeiboAccount *)account
{
    if (!mentions.count) return;
    
    if (account.notificationOptions & WeiboMentionNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        WeiboBaseStatus * status = mentions.firstObject;
        WeiboUser * user = status.user;
        WeiboUserNotificationItemType type = 0;
        
        if (mentions.count > 1)
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"%zd new mentions from @%@ and others", nil), mentions.count, user.screenName];
            notification.informativeText = NSLocalizedString(@"Click here to view it now.", nil);
            type = WeiboUserNotificationItemTypeMentions;
        }
        else
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"@%@ mentioned you in a status", nil), user.screenName];
            notification.informativeText = status.text;
            
            if ([notification respondsToSelector:@selector(setHasReplyButton:)])
            {
                notification.hasReplyButton = YES;
            }
            type = WeiboUserNotificationItemTypeMention;
        }
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:@(type) forKey:WeiboUserNotificationUserInfoItemTypeKey];
        [userInfo setObject:@(user.userID) forKey:WeiboUserNotificationUserInfoItemUserIDKey];
        [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}
- (void)scheduleNotificationForComments:(NSArray *)comments forAccount:(WeiboAccount *)account
{
    if (!comments.count) return;
    
    if (account.notificationOptions & WeiboCommentNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        WeiboBaseStatus * status = comments.firstObject;
        WeiboUser * user = status.user;
        WeiboUserNotificationItemType type = 0;
        
        if (comments.count > 1)
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"%zd new comments from @%@ and others", nil), comments.count, user.screenName];
            notification.informativeText = NSLocalizedString(@"Click here to view it now.", nil);
            type = WeiboUserNotificationItemTypeComments;
        }
        else
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"@%@ replied your status", nil), user.screenName];
            notification.informativeText = status.text;
            
            if ([notification respondsToSelector:@selector(setHasReplyButton:)])
            {
                notification.hasReplyButton = YES;
            }
            type = WeiboUserNotificationItemTypeComment;
        }
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:@(type) forKey:WeiboUserNotificationUserInfoItemTypeKey];
        [userInfo setObject:@(user.userID) forKey:WeiboUserNotificationUserInfoItemUserIDKey];
        [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}
- (void)scheduleNotificationForDirectMessages:(NSArray *)messages forAccount:(WeiboAccount *)account
{
    if (!messages.count) return;
    
    if (account.notificationOptions & WeiboDirectMessageNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        WeiboDirectMessage * message = messages.firstObject;
        WeiboUser * user = message.sender;
        WeiboUserNotificationItemType type = 0;
        
        if (messages.count > 1)
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"%zd new messages from @%@ and others", nil), messages.count, user.screenName];
            notification.informativeText = NSLocalizedString(@"Click here to view it now.", nil);
            type = WeiboUserNotificationItemTypeDirectMessages;
        }
        else
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"@%@ send you a message", nil), user.screenName];
            notification.informativeText = message.text;
            
            if ([notification respondsToSelector:@selector(setHasReplyButton:)])
            {
                notification.hasReplyButton = YES;
            }
            type = WeiboUserNotificationItemTypeDirectMessage;
        }
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:@(type) forKey:WeiboUserNotificationUserInfoItemTypeKey];
        [userInfo setObject:@(user.userID) forKey:WeiboUserNotificationUserInfoItemUserIDKey];
        [userInfo setObject:@(message.messageID) forKey:WeiboUserNotificationUserInfoItemIDKey];
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}

#pragma mark - NSUserNotificationCenter Delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    
}

@end
