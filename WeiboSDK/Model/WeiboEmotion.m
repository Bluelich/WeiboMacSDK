//
//  WeiboEmotion.m
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboEmotion.h"
#import "WeiboCallback.h"
#import "JSONKit.h"

@implementation WeiboEmotion
@synthesize phrase = _phrase, type = _type, url = _url;
@synthesize hot = _hot, common = _common, category = _category;

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.phrase = [dict objectForKey:@"phrase"];
        self.type = [dict objectForKey:@"type"];
        self.url = [dict objectForKey:@"url"];
        self.hot = [[dict objectForKey:@"hot"] boolValue];
        self.common = [[dict objectForKey:@"common"] boolValue];
        self.category = [dict objectForKey:@"category"];
        return YES;
    }
    return NO;
}

- (NSString *)fileName
{
    return [[self.url componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"phrase:%@",self.phrase];
}

@end
