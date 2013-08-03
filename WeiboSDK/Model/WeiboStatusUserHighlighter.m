//
//  WeiboStatusUserHighlighter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusUserHighlighter.h"
#import "WeiboBaseStatus.h"

@implementation WeiboStatusUserHighlighter

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if ([super validateStatus:status])
    {
        status.isSpecial = YES;
    }
    
    return NO;
}

@end
