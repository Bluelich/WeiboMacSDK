//
//  WeiboStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WeiboBaseStatus.h"

@class WeiboUser, WeiboGeotag, WTCallback;

@interface WeiboStatus : WeiboBaseStatus {
    BOOL truncated;
    WeiboStatus * retweetedStatus;
    WeiboStatusID inReplyToStatusID;
    WeiboGeotag * geo;
    BOOL favorited;
    WeiboUserID inReplyToUserID;
    NSString * inReplyToScreenname;
    NSString * source;
    NSString * sourceUrl;
    NSString * thumbnailPic;
    NSString * middlePic;
    NSString * originalPic;
}

@property (assign, nonatomic) BOOL truncated;
@property (retain, nonatomic) WeiboStatus * retweetedStatus;
@property (assign, nonatomic) WeiboStatusID inReplyToStatusID;
@property (retain, nonatomic) WeiboGeotag * geo;
@property (assign, nonatomic) BOOL favorited;
@property (assign, nonatomic) WeiboUserID inReplyToUserID;
@property (assign, nonatomic) NSString * inReplyToScreenname;
@property (retain, nonatomic) NSString * source;
@property (retain, nonatomic) NSString * sourceUrl;
@property (retain, nonatomic) NSString * thumbnailPic;
@property (retain, nonatomic) NSString * middlePic;
@property (retain, nonatomic) NSString * originalPic;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboStatus *)statusWithDictionary:(NSDictionary *)dic;
+ (WeiboStatus *)statusWithJSON:(NSString *)json;
+ (NSArray *)statusesWithJSON:(NSString *)json;
+ (void)parseStatusesJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseStatusJSON:(NSString *)json callback:(WTCallback *)callback;
@end
