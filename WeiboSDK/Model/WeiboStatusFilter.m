//
//  WeiboStatusFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusFilter.h"

@implementation WeiboStatusFilter

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.createTime = [aDecoder decodeDoubleForKey:@"create-time"];
        self.expireTime = [aDecoder decodeDoubleForKey:@"expire-time"];
        self.filterQuotedStatus = [aDecoder decodeBoolForKey:@"filter-quoted-status"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.createTime forKey:@"create-time"];
    [aCoder encodeDouble:self.expireTime forKey:@"expire-time"];
    [aCoder encodeBool:self.filterQuotedStatus forKey:@"filter-quoted-status"];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    return NO;
}

- (NSTimeInterval)duration
{
    return self.expireTime - self.createTime;
}

@end
