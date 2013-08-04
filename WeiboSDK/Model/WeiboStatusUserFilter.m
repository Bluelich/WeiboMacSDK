//
//  WeiboStatusUserFilter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusUserFilter.h"
#import "WeiboBaseStatus.h"
#import "WeiboUser.h"

@implementation WeiboStatusUserFilter

- (void)dealloc
{
    [_screenname release], _screenname = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.screenname = [aDecoder decodeObjectForKey:@"screenname"];
        self.userID = [[aDecoder decodeObjectForKey:@"user-id"] longLongValue];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.screenname forKey:@"screenname"];
    [aCoder encodeObject:@(self.userID) forKey:@"user-id"];
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (!self.screenname.length && !self.userID)
    {
        return NO;
    }
    
    if (self.userID)
    {
        return status.user.userID == self.userID;
    }
    else if (self.screenname)
    {
        return [status.user.screenName isEqual:self.screenname];
    }
    
    if (self.filterQuotedStatus && status.quotedBaseStatus)
    {
        return [self validateStatus:status.quotedBaseStatus];
    }
    
    return NO;
}

@end
