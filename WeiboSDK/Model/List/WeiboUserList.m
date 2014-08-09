//
//  WeiboUserList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserList.h"

@implementation WeiboUserList

- (void)dealloc
{
    _loadNewerError = nil;
    _loadOlderError = nil;
}

- (id)initWithCoder:(NSCoder * __attribute__((unused)))aDecoder
{
    if (self = [self init])
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder * __attribute__((unused)))aCoder
{
    
}

- (NSArray *)users
{
    return nil;
}

- (void)loadNewer
{
    
}

- (void)loadOlder
{
    
}

- (BOOL)isEnded
{
    return NO;
}
- (void)retryLoadOlder
{
    
}

@end
