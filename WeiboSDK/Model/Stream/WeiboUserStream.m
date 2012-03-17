//
//  WeiboUserStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUserStream.h"

@implementation WeiboUserStream
@synthesize user;

- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"user/%ld/"];
}

@end
