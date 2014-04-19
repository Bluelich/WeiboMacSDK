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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        WeiboUser * user = [aDecoder decodeObjectForKey:@"user"];
        
        if (![user isKindOfClass:[WeiboUser class]]) return nil;
        
        self.user = user;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.user forKey:@"user"];
}

- (NSString *)autosaveName{
    return [[super autosaveName] stringByAppendingFormat:@"user/%lld/",self.user.userID];
}

@end
