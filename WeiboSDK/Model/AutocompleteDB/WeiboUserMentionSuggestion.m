//
//  WeiboUserMentionSuggestion.m
//  Weibo
//
//  Created by Wutian on 13-12-21.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserMentionSuggestion.h"
#import <NSDictionary+Accessors.h>

@implementation WeiboUserMentionSuggestion

- (void)dealloc
{
    _screenName = nil;
    _remark = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init])
    {
        self.userID = (WeiboUserID)[dict longLongForKey:@"uid"];
        self.screenName = [dict stringForKey:@"nickname"] ? : @"";
        self.remark = [dict stringForKey:@"remark"] ? : @"";
    }
    return self;
}

+ (NSArray *)suggestionsWithJSONArray:(NSArray *)array
{
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSDictionary * dict in array)
    {
        WeiboUserMentionSuggestion * suggestion = [[self alloc] initWithDictionary:dict];
        
        if (suggestion.userID)
        {
            [result addObject:suggestion];
        }
        
    }
    
    return result;
}

@end
