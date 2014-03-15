//
//  WeiboFavoriteStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-5-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboFavoriteStatus.h"
#import "JSONKit.h"

@implementation WeiboFavoriteStatus

+ (NSArray *)statusesWithJSON:(NSString *)json{
    NSArray * dictionaries = [[json objectFromJSONString] objectForKey:@"favorites"];
    NSMutableArray * statuses = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboFavoriteStatus * status = [WeiboFavoriteStatus statusWithDictionary:dic];
        [statuses addObject:status];
    }
    return statuses;
}

- (id)initWithDictionary:(NSDictionary *)dic{
    if (self = [super initWithDictionary:[dic objectForKey:@"status"]]) {
        self.favorited = YES;
    }
    return self;
}

@end
