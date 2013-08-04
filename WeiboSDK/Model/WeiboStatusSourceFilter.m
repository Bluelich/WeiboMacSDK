//
//  WeiboStatusSourceFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusSourceFilter.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"

@implementation WeiboStatusSourceFilter

- (void)dealloc
{
    [_source release], _source = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.source = [aDecoder decodeObjectForKey:@"source"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.source forKey:@"source"];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (!self.source.length)
    {
        return NO;
    }
    
    if ([status isKindOfClass:[WeiboStatus class]])
    {
        return [[(WeiboStatus *)status source] isEqual:self.source];
    }
    
    return NO;
}

@end
