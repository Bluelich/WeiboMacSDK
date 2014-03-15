//
//  WeiboUserStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUserStream.h"
#import "WeiboUser.h"

@implementation WeiboUserStream
@synthesize user = _user;

- (void)dealloc
{
    _user = nil;
}

- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"user/%lld/",self.user.userID];
}

@end
