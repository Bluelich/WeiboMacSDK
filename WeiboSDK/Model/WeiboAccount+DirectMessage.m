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

- (NSString *)directMessageCachePathWithTypeString:(NSString *)typeString
{
    NSString * directory = [WeiboFileManager subCacheDirectory:@"messages"];
    return [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld_%@.zip", self.user.userID, typeString]];
}

- (void)saveDirectMessages
{
    if (self.privateMessagesManager) {
        [NSKeyedArchiver archiveRootObject:self.privateMessagesManager toFile:[self directMessageCachePathWithTypeString:@"private"]];
    }
    
    if (self.publicMessagesManager) {
        [NSKeyedArchiver archiveRootObject:self.privateMessagesManager toFile:[self directMessageCachePathWithTypeString:@"public"]];
    }
}

- (WeiboPrivateMessagesConversationManager *)restorePrivateMessageManager
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self directMessageCachePathWithTypeString:@"private"]];
    
    if ([object isKindOfClass:[WeiboPrivateMessagesConversationManager class]])
    {
        [object setAccount:self];
        
        return (WeiboPrivateMessagesConversationManager *)object;
    }
    
    return nil;
}

- (WeiboPublicMessagesConversationManager *)restorePublicMessageManager
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self directMessageCachePathWithTypeString:@"public"]];
    
    if ([object isKindOfClass:[WeiboPublicMessagesConversationManager class]])
    {
        [object setAccount:self];
        
        return (WeiboPublicMessagesConversationManager *)object;
    }
    
    return nil;
}

@end
