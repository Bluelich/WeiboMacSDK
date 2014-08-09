//
//  WeiboStatusStreamFilter.m
//  Weibo
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStatusStreamFilter.h"

@implementation WeiboStatusStreamFilter

static id _defaultFilter;

+ (id)defaultStatusStreamFilter{
    if (!_defaultFilter) {
        _defaultFilter = [[[self class] alloc] init];
    }
    return _defaultFilter;
}
- (BOOL)validStatus:(WeiboBaseStatus * __attribute__((unused)))status
{
    // subclass should implement.
    return YES;
}

@end
