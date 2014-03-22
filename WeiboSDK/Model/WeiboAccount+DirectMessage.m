//
//  WeiboAccount+DirectMessage.m
//  Weibo
//
//  Created by Wutian on 13-9-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccount+DirectMessage.h"
#import "WeiboFileManager.h"

@implementation WeiboAccount (DirectMessage)

- (NSString *)directMessageCachePath
{
    NSString * directory = [WeiboFileManager subCacheDirectory:@"messages"];
    return [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.zip", self.user.userID]];
}

- (void)saveDirectMessages
{
    if (self.directMessagesManager)
    {
        [NSKeyedArchiver archiveRootObject:self.directMessagesManager toFile:[self directMessageCachePath]];
    }
}
- (WeiboDirectMessagesConversationManager *)restoreDirectMessageManager
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self directMessageCachePath]];
    
    if ([object isKindOfClass:[WeiboDirectMessagesConversationManager class]])
    {
        [object setAccount:self];
        
        return (WeiboDirectMessagesConversationManager *)object;
    }
    
    return nil;
}

@end
