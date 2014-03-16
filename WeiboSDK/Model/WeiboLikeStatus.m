//
//  WeiboLikeStatus.m
//  Weibo
//
//  Created by Wutian on 14-3-9.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboLikeStatus.h"

@implementation WeiboLikeStatus

- (NSString *)text
{
    return NSLocalizedString(@"Like!", nil);
}
- (BOOL)canHaveConversation
{
    return NO;
}
- (BOOL)canReply
{
    return NO;
}

+ (NSString *)defaultJSONArrayRootKey
{
    return @"attitudes";
}

@end
