//
//  WeiboEmotion.h
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTCallback;

@interface WeiboEmotion : NSObject

@property (nonatomic, strong) NSString * phrase;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, assign) BOOL hot;
@property (nonatomic, assign) BOOL common;
@property (nonatomic, strong) NSString * category;
@property (weak, nonatomic, readonly) NSString * fileName;

+ (WeiboEmotion *)emotionWithDictionary:(NSDictionary *)dic;
+ (WeiboEmotion *)emotionWithJSON:(NSString *)json;
+ (NSArray *)emotionsWithJSON:(NSString *)json;
+ (void)parseEmotionsJSON:(NSString *)json callback:(WTCallback *)callback;
- (WeiboEmotion *)initWithDictionary:(NSDictionary *)dic;

@end
