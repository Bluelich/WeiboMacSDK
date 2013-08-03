//
//  WeiboStatusKeywordFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusKeywordFilter.h"
#import "WeiboBaseStatus.h"

@implementation WeiboStatusKeywordFilter

- (void)dealloc
{
    [_keyword release], _keyword = nil;
    [super dealloc];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (!self.keyword.length)
    {
        return NO;
    }
    
    if ([status.text rangeOfString:self.keyword].length)
    {
        return YES;
    }
    
    if ([status.quotedBaseStatus.text rangeOfString:self.keyword].length)
    {
        return YES;
    }
    
    return NO;
}

@end
