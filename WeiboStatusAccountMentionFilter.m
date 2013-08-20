//
//  WeiboStatusAccountMentionFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-20.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusAccountMentionFilter.h"
#import "WeiboBaseStatus.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"

@implementation WeiboStatusAccountMentionFilter

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    NSString * screenName = [NSString stringWithFormat:@"@%@", self.account.user.screenName];
    
    if ([status.text rangeOfString:screenName].length != 0)
    {
        status.mentionedMe = YES;
        
        return NO;
    }
    
    if (status.quotedBaseStatus)
    {
        return [self validateStatus:status.quotedBaseStatus];
    }
    
    return NO;
}

@end
