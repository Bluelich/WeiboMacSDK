//
//  WeiboStatusStreamFilterSimpleSearchFilter.m
//  Weibo
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStatusStreamFilterSimpleSearchFilter.h"
#import "WeiboBaseStatus.h"

@implementation WeiboStatusStreamFilterSimpleSearchFilter
@synthesize query = _query;

- (void)dealloc{
    [_query release];
    [super dealloc];
}

- (BOOL)validStatus:(WeiboBaseStatus *)status{
    NSString * text = status.displayText.string;
    if ([text rangeOfString:self.query 
                    options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
