//
//  WeiboUserNotificationCenter.m
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserNotificationCenter.h"

@interface WeiboUserNotificationCenter () <NSUserNotificationCenterDelegate>

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
    static WeiboUserNotificationCenter * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:instance];
        
        [instance performSelector:@selector(demo) withObject:nil afterDelay:5.0];
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

- (void)_scheduleUserNotification:(NSUserNotification *)notification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

- (void)scheduleNotificationForMentions:(NSArray *)mentions forAccount:(WeiboAccount *)account
{
    NSUserNotification * notification = [[NSUserNotification alloc] init];
    
    [notification autorelease];
}
- (void)scheduleNotificationForComments:(NSArray *)comments forAccount:(WeiboAccount *)account
{
    
}
- (void)scheduleNotificationForDirectMessages:(NSArray *)messages forAccount:(WeiboAccount *)account
{
    
}

#pragma mark - NSUserNotificationCenter Delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{

}

- (void)demo
{
    NSUserNotification * notification = [[[NSUserNotification alloc] init] autorelease];
    
    notification.title = @"这是标题这是标题这是标题这是标题这是标题这是标题这是标题";
    notification.subtitle = @"这是副标题这是副标题这是副标题这是副标题这是副标题这是副标题这是副标题";
    notification.informativeText = @"这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容";
//    notification.actionButtonTitle = @"回复";
//    notification.otherButtonTitle = @"查看";
    notification.hasReplyButton = YES;
    
    [self _scheduleUserNotification:notification];
}

@end
