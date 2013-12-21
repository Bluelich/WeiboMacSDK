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
    [_screenName release], _screenName = nil;
    [_remark release], _remark = nil;
    [super dealloc];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init])
    {
        self.userID = [dict longlongForKey:@"uid" defaultValue:0];
        self.screenName = [dict stringForKey:@"nickname" defaultValue:@""];
        self.remark = [dict stringForKey:@"remark" defaultValue:@""];
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
        
        [suggestion release];
    }
    
    return result;
}

@end
