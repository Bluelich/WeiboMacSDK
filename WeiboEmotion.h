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

@property (nonatomic, retain) NSString * phrase;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, assign) BOOL hot;
@property (nonatomic, assign) BOOL common;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, readonly) NSString * fileName;

+ (WeiboEmotion *)emotionWithDictionary:(NSDictionary *)dic;
+ (WeiboEmotion *)emotionWithJSON:(NSString *)json;
+ (NSArray *)emotionsWithJSON:(NSString *)json;
+ (void)parseEmotionsJSON:(NSString *)json callback:(WTCallback *)callback;
- (WeiboEmotion *)initWithDictionary:(NSDictionary *)dic;

@end
