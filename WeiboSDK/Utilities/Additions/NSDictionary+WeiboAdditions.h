//
//  NSDictionary+WeiboAdditions.h
//  Weibo
//
//  Created by Wu Tian on 12-2-15.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WeiboAdditions)

- (BOOL)weibo_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)weibo_intForKey:(NSString *)key defaultValue:(int)defaultValue;
- (time_t)weibo_timeForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)weibo_longlongForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)weibo_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

@end
