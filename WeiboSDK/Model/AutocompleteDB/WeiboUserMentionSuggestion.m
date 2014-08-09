//
//  WeiboUserMentionSuggestion.m
//  Weibo
//
//  Created by Wutian on 13-12-21.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserMentionSuggestion.h"
#import "NSDictionary+WeiboAdditions.h"

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
        self.userID = (WeiboUserID)[dict weibo_longlongForKey:@"uid" defaultValue:0];
        self.screenName = [dict weibo_stringForKey:@"nickname" defaultValue:@""];
        self.remark = [dict weibo_stringForKey:@"remark" defaultValue:@""];
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
