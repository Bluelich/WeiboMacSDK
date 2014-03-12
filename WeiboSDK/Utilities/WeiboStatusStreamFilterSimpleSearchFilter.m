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


- (BOOL)validStatus:(WeiboBaseStatus *)status{
    
    if (status.isDummy) return NO;
    
    WeiboUser * user = status.user;
    NSString * query = self.query;
    
    if (status.text && [status.text rangeOfString:query
                    options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (user.screenName && [user.screenName rangeOfString:query
                                           options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (user.remark && [user.remark rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return YES;
    }
    
    if (status.quotedBaseStatus)
    {
        WeiboBaseStatus * quotedStatus = status.quotedBaseStatus;
        WeiboUser * quotedUser = quotedStatus.user;
        
        if (quotedStatus.text && [quotedStatus.text rangeOfString:query
                                               options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
        if (quotedUser.screenName && [quotedUser.screenName rangeOfString:query
                                                          options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
        if (quotedUser.remark && [quotedUser.remark rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            return YES;
        }
    }
    return NO;
}

@end
