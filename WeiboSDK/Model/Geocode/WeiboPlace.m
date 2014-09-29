//
//  WeiboPlace.m
//  Weibo
//
//  Created by Wutian on 14/9/29.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboPlace.h"

@implementation WeiboPlace

+ (NSString *)defaultJSONArrayRootKey
{
    return @"geos";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict]) {
        return YES;
    }
    return NO;
}

@end
