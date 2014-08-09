//
//  WeiboSavedSearch.m
//  Weibo
//
//  Created by Wutian on 13-12-25.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboSavedSearch.h"

@implementation WeiboSavedSearch

- (void)dealloc
{
    _keyword = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        self.keyword = [aDecoder decodeObjectForKey:@"keyword"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.keyword forKey:@"keyword"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (NSUInteger)hash
{
    return ((self.keyword.hash + 1) * ((NSUInteger)self.type + 1));
}

- (BOOL)isEqual:(WeiboSavedSearch *)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[WeiboSavedSearch class]]) return NO;
    
    return ([self.keyword isEqual:object.keyword] && self.type == object.type);
}

@end
