//
//  WeiboStatusStreamFilterSimpleSearchFilter.m
//  Weibo
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStatusStreamFilterSimpleSearchFilter.h"
#import "WeiboBaseStatus.h"
#import "WeiboUser.h"

@implementation WeiboStatusStreamFilterSimpleSearchFilter
@synthesize query = _query;

- (void)dealloc{
    [_query release];
    [super dealloc];
}

- (BOOL)validStatus:(WeiboBaseStatus *)status{
    if ([status.text rangeOfString:self.query 
                    options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if ([status.user.screenName rangeOfString:self.query
                                           options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    if (status.quotedBaseStatus)
    {
        if ([status.quotedBaseStatus.text rangeOfString:self.query
                                               options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
        if ([status.quotedBaseStatus.user.screenName rangeOfString:self.query
                                                          options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

@end
