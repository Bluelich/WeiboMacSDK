//
//  WeiboEmotion.m
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboEmotion.h"
#import "WTCallback.h"
#import "JSONKit.h"

@implementation WeiboEmotion
@synthesize phrase = _phrase, type = _type, url = _url;
@synthesize hot = _hot, common = _common, category = _category;

- (void)dealloc{
    [_phrase release];
    [_type release];
    [_url release];
    [_category release];
    [super dealloc];
}

+ (WeiboEmotion *)emotionWithDictionary:(NSDictionary *)dic{
    return [[[[self class] alloc] initWithDictionary:dic] autorelease];
}
+ (WeiboEmotion *)emotionWithJSON:(NSString *)json{
    NSDictionary * dic = [json objectFromJSONString];
    return [self emotionWithDictionary:dic];
}
+ (NSArray *)emotionsWithJSON:(NSString *)json{
    NSArray * dictionaries = [json objectFromJSONString];
    NSMutableArray * emotions = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboEmotion * emotion = [WeiboEmotion emotionWithDictionary:dic];
        [emotions addObject:emotion];
    }
    return emotions;
}
+ (void)parseEmotionsJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSArray * emotions = [self emotionsWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:emotions];
            [json release];
        });
    });
}
- (WeiboEmotion *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.phrase = [dic objectForKey:@"phrase"];
        self.type = [dic objectForKey:@"type"];
        self.url = [dic objectForKey:@"url"];
        self.hot = [[dic objectForKey:@"hot"] boolValue];
        self.common = [[dic objectForKey:@"common"] boolValue];
        self.category = [dic objectForKey:@"category"];
    }
    return self;
}

- (NSString *)fileName{
    return [[self.url componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"phrase:%@",self.phrase];
}

@end
