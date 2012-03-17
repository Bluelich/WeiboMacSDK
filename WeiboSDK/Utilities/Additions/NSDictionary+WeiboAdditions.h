//
//  NSDictionary+WeiboAdditions.h
//  Weibo
//
//  Created by Wu Tian on 12-2-15.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WeiboAdditions)

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)intForKey:(NSString *)key defaultValue:(int)defaultValue;
- (time_t)timeForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)longlongForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

@end
