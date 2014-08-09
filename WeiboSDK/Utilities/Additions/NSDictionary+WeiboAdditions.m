//
//  NSDictionary+WeiboAdditions.m
//  Weibo
//
//  Created by Wu Tian on 12-2-15.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "NSDictionary+WeiboAdditions.h"

@implementation NSDictionary (WeiboAdditions)

- (BOOL)weibo_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue{
    return [self objectForKey:key] == [NSNull null] ? defaultValue 
    : [[self objectForKey:key] boolValue];
}
- (int)weibo_intForKey:(NSString *)key defaultValue:(int)defaultValue{
    return [self objectForKey:key] == [NSNull null] 
    ? defaultValue : [[self objectForKey:key] intValue];
}
- (time_t)weibo_timeForKey:(NSString *)key defaultValue:(time_t)defaultValue{
    NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}
- (long long)weibo_longlongForKey:(NSString *)key defaultValue:(long long)defaultValue{
    return [self objectForKey:key] == [NSNull null] 
    ? defaultValue : [[self objectForKey:key] longLongValue];
}
- (NSString *)weibo_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue{
    
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null])
    {
        return defaultValue;
    }
    
    id result = [self objectForKey:key];
    
    if ([result isKindOfClass:[NSString class]])
    {
        return result;
    }
    else if ([result isKindOfClass:[NSNumber class]])
    {
        return [result stringValue];
    }
    
    return defaultValue;
}

@end
