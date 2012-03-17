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
    NSString * thumbnailPic;
    NSString * middlePic;
    NSString * originalPic;
}

@property (assign, readwrite) BOOL truncated;
@property (retain, readwrite) WeiboStatus * retweetedStatus;
@property (assign, readwrite) WeiboStatusID inReplyToStatusID;
@property (retain, readwrite) WeiboGeotag * geo;
@property (assign, readwrite) BOOL favorited;
@property (assign, readwrite) WeiboUserID inReplyToUserID;
@property (assign, readwrite) NSString * inReplyToScreenname;
@property (retain, readwrite) NSString * source;
@property (retain, readwrite) NSString * thumbnailPic;
@property (retain, readwrite) NSString * middlePic;
@property (retain, readwrite) NSString * originalPic;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboStatus *)statusWithDictionary:(NSDictionary *)dic;
+ (WeiboStatus *)statusWithJSON:(NSString *)json;
+ (NSArray *)statusesWithJSON:(NSString *)json;
+ (void)parseStatusesJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseStatusJSON:(NSString *)json callback:(WTCallback *)callback;
@end
