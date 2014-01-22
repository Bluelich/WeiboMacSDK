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
#import "WeiboComment.h"
#import "WeiboStatus.h"
#import "WeiboDirectMessage.h"
#import "Weibo.h"

NSString * const WeiboUserNotificationUserInfoItemTypeKey = @"WeiboUserNotificationUserInfoItemTypeKey";
NSString * const WeiboUserNotificationUserInfoItemUserIDKey = @"WeiboUserNotificationUserInfoItemUserIDKey";
NSString * const WeiboUserNotificationUserInfoItemUserDataKey = @"WeiboUserNotificationUserInfoItemUserDataKey";
NSString * const WeiboUserNotificationUserInfoItemIDKey = @"WeiboUserNotificationUserInfoItemIDKey";
NSString * const WeiboUserNotificationUserInfoCommentIDKey = @"WeiboUserNotificationUserInfoCommentIDKey";

NSString * const WeiboUserNotificationUserInfoAccountUserIDKey = @"WeiboUserNotificationUserInfoAccountUserIDKey";

NSString * const WeiboUserNotificationCenterActivatedNotificationNotification = @"WeiboUserNotificationCenterActivatedNotificationNotification";
NSString * const WeiboUserNotificationCenterUserInfoNSUserNotificationKey = @"WeiboUserNotificationCenterUserInfoNSUserNotificationKey";
NSString * const WeiboUserNotificationCenterUserInfoAccountKey = @"WeiboUserNotificationCenterUserInfoAccountKey";
NSString * const WeiboUserNotificationCenterUserInfoImportantFlagKey = @"WeiboUserNotificationCenterUserInfoImportantFlagKey";

@interface WeiboUserNotificationCenter () <NSUserNotificationCenterDelegate>

@end

@implementation WeiboUserNotificationCenter

- (void)dealloc
{
    [super dealloc];
}

static BOOL AtLeastMountainLion = NO;
static BOOL AtLeaseMavericks    = NO;

+ (void)initialize
{
    SInt32 major = 0;
    SInt32 minor = 0;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    AtLeastMountainLion = (major == 10 && minor >= 8);
    AtLeaseMavericks    = (major == 10 && minor >= 9);
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

+ (BOOL)supportsDirectlyReply
{
    return AtLeaseMavericks;
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

- (NSArray *)itemsNotAuthoredByAccount:(WeiboAccount *)account fromItems:(NSArray *)items
{
    NSMutableArray * result = [NSMutableArray array];
    
    for (id item in items)
    {
        BOOL valid = NO;
        
        if ([item isKindOfClass:[WeiboBaseStatus class]])
        {
            valid = ![account.user isEqual:[item user]];
        }
        else if ([item isKindOfClass:[WeiboDirectMessage class]])
        {
            valid = ![account.user isEqual:[item sender]];
        }
        
        if (valid) [result addObject:item];
    }
    return result;
}

- (void)_scheduleUserNotification:(NSUserNotification *)notification
{
    [self _scheduleUserNotification:notification playSound:YES];
}
- (void)_scheduleUserNotification:(NSUserNotification *)notification playSound:(BOOL)playSound
{
    if (playSound)
    {
        notification.soundName = NSUserNotificationDefaultSoundName;
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)scheduleNotificationForStatuses:(NSArray *)statuses forAccount:(WeiboAccount *)account
{
    NSMutableArray * result = [NSMutableArray array];
    
    WeiboUser * accountUser = account.user;
    
    for (WeiboBaseStatus * status in statuses)
    {
        if ([accountUser isEqual:status.user]) continue;
        if (status.quotedBaseStatus) continue;
        if (!status.user.followMe) continue;
        
        [result addObject:status];
    }
    
    if (account.notificationOptions & WeiboTweetNotificationSystemCenter)
    {
        for (WeiboBaseStatus * status in [result reverseObjectEnumerator])
        {
            NSUserNotification * notification = [[NSUserNotification alloc] init];
            
            notification.title = status.user.screenName;
            notification.informativeText = status.text;
            
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
            
            [userInfo setObject:@(WeiboUserNotificationItemTypeStatus) forKey:WeiboUserNotificationUserInfoItemTypeKey];
            [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
            [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
            
            [notification setUserInfo:userInfo];
            
            [self _scheduleUserNotification:notification playSound:NO];
        }
    }
}

- (void)scheduleNotificationForMentions:(NSArray *)mentions forAccount:(WeiboAccount *)account
{
    mentions = [self itemsNotAuthoredByAccount:account fromItems:mentions];
    
    if (!mentions.count) return;
    
    if (account.notificationOptions & WeiboMentionNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        WeiboBaseStatus * status = mentions.firstObject;
        WeiboUser * user = status.user;
        WeiboUserNotificationItemType type = 0;
        
        BOOL isCommentMention = [status isKindOfClass:[WeiboComment class]];
        
        if (mentions.count > 1)
        {
            notification.title = [NSString stringWithFormat:NSLocalizedString(@"%zd new mentions from @%@ and others", nil), mentions.count, user.screenName];
            notification.informativeText = NSLocalizedString(@"Click here to view it now.", nil);
            type = isCommentMention ? WeiboUserNotificationItemTypeCommentMentions :  WeiboUserNotificationItemTypeStatusMentions;
        }
        else
        {
            if (isCommentMention)
            {
                notification.title = [NSString stringWithFormat:NSLocalizedString(@"@%@ mentioned you in a comment", nil), user.screenName];
            }
            else
            {
                notification.title = [NSString stringWithFormat:NSLocalizedString(@"@%@ mentioned you in a status", nil), user.screenName];
            }
            notification.informativeText = status.text;
            
            if ([[self class] supportsDirectlyReply])
            {
                notification.hasReplyButton = YES;
            }
            type = isCommentMention ? WeiboUserNotificationItemTypeCommentMention :  WeiboUserNotificationItemTypeStatusMention;
        }
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:@(type) forKey:WeiboUserNotificationUserInfoItemTypeKey];
        [userInfo setObject:@(user.userID) forKey:WeiboUserNotificationUserInfoItemUserIDKey];
        
        if (isCommentMention)
        {
            WeiboComment * comment = (WeiboComment *)status;
            
            [userInfo setObject:@(comment.replyToStatus.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
            [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoCommentIDKey];
        }
        else
        {
            [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
        }
        
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}
- (void)scheduleNotificationForComments:(NSArray *)comments forAccount:(WeiboAccount *)account
{
    comments = [self itemsNotAuthoredByAccount:account fromItems:comments];
    
    if (!comments.count) return;
    
    if (account.notificationOptions & WeiboCommentNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        WeiboComment * status = comments.firstObject;
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
        [userInfo setObject:@(status.replyToStatus.sid) forKey:WeiboUserNotificationUserInfoItemIDKey];
        [userInfo setObject:@(status.sid) forKey:WeiboUserNotificationUserInfoCommentIDKey];
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}
- (void)scheduleNotificationForDirectMessages:(NSArray *)messages forAccount:(WeiboAccount *)account
{
    messages = [self itemsNotAuthoredByAccount:account fromItems:messages];
    
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
        
        if (user)
        {
            [userInfo setObject:@(user.userID) forKey:WeiboUserNotificationUserInfoItemUserIDKey];
            
            BOOL simplifiedCoding = user.simplifiedCoding;
            
            user.simplifiedCoding = YES;
            
            NSData * userData = [NSKeyedArchiver archivedDataWithRootObject:user];
            [userInfo setObject:userData forKey:WeiboUserNotificationUserInfoItemUserDataKey];
            
            user.simplifiedCoding = simplifiedCoding;
        }
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}

- (void)scheduleNotificationForNewFollowersCount:(NSInteger)count forAccount:(WeiboAccount *)account
{
    if (account.notificationOptions & WeiboFollowerNotificationSystemCenter)
    {
        NSUserNotification * notification = [[NSUserNotification alloc] init];
        
        notification.title = [NSString stringWithFormat:NSLocalizedString(@"You have %d new followers", nil), count];
        notification.informativeText = NSLocalizedString(@"Click here to view it now.", nil);
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:@(WeiboUserNotificationItemTypeFollower) forKey:WeiboUserNotificationUserInfoItemTypeKey];
        [userInfo setObject:@(account.user.userID) forKey:WeiboUserNotificationUserInfoAccountUserIDKey];
        
        [notification setUserInfo:userInfo];
        
        [self _scheduleUserNotification:notification];
        [notification autorelease];
    }
}

#pragma mark - NSUserNotificationCenter Delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if (!notification) return;
    
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
    
    WeiboUserID accountUserID = [notification.userInfo[WeiboUserNotificationUserInfoAccountUserIDKey] longLongValue];
    if (accountUserID)
    {
        WeiboAccount * account = [[Weibo sharedWeibo] accountWithUserID:accountUserID];
        
        if (!account) return; // if there is a account userID but account object, it's unnecessary to handle this activation.
        
        [userInfo setObject:account forKey:WeiboUserNotificationCenterUserInfoAccountKey];
    }
    
    [userInfo setObject:notification forKey:WeiboUserNotificationCenterUserInfoNSUserNotificationKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUserNotificationCenterActivatedNotificationNotification object:self userInfo:userInfo];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    if ([[notification.userInfo objectForKey:WeiboUserNotificationCenterUserInfoImportantFlagKey] boolValue])
    {
        return YES;
    }
    return NO;
}

@end
