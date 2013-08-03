//
//  WeiboStatusSourceFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusSourceFilter.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"

@implementation WeiboStatusSourceFilter

- (void)dealloc
{
    [_source release], _source = nil;
    [super dealloc];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (!self.source.length)
    {
        return NO;
    }
    
    if ([status isKindOfClass:[WeiboStatus class]])
    {
        return [[(WeiboStatus *)status source] isEqual:self.source];
    }
    
    return NO;
}

@end
