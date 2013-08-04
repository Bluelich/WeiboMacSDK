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
        self.createTime = [[aDecoder decodeObjectForKey:@"create-time"] doubleValue];
        self.expireTime = [[aDecoder decodeObjectForKey:@"expire-time"] doubleValue];
        self.filterQuotedStatus = [[aDecoder decodeObjectForKey:@"filter-quoted-status"] boolValue];
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.createTime) forKey:@"create-time"];
    [aCoder encodeObject:@(self.expireTime) forKey:@"expire-time"];
    [aCoder encodeObject:@(self.filterQuotedStatus) forKey:@"filter-quoted-status"];
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
