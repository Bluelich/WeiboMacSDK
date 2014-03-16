//
//  WeiboFavoriteStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-5-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboFavoriteStatus.h"
#import "JSONKit.h"

@implementation WeiboFavoriteStatus

+ (NSString *)defaultJSONArrayRootKey
{
    return @"favorites";
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super initWithJSONDictionary:[dict objectForKey:@"status"]])
    {
        self.favorited = YES;
    }
    return self;
}

@end
