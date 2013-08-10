//
//  WeiboStatusKeywordFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusKeywordFilter.h"
#import "WeiboBaseStatus.h"

@implementation WeiboStatusKeywordFilter

- (void)dealloc
{
    [_keyword release], _keyword = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        self.filterQuotedStatus = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.keyword = [aDecoder decodeObjectForKey:@"keyword"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.keyword forKey:@"keyword"];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (!self.keyword.length)
    {
        return NO;
    }
    
    if ([status.text rangeOfString:self.keyword].length)
    {
        return YES;
    }
    
    if (self.filterQuotedStatus && status.quotedBaseStatus)
    {
        return [self validateStatus:status.quotedBaseStatus];
    }
    
    return NO;
}

- (NSString *)title
{
    return self.keyword;
}

@end
