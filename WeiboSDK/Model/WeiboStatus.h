//
//  WeiboStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboBaseStatus.h"

@class WeiboUser, WeiboGeotag, WeiboCallback;

@interface WeiboStatus : WeiboBaseStatus {
    BOOL truncated;
    WeiboStatus * retweetedStatus;
    WeiboStatusID inReplyToStatusID;
    WeiboGeotag * geo;
    BOOL favorited;
    WeiboUserID inReplyToUserID;
    NSString * __weak inReplyToScreenname;
    NSString * source;
    NSString * sourceUrl;
}

@property (assign, nonatomic) BOOL truncated;
@property (strong, atomic) WeiboStatus * retweetedStatus;
@property (assign, nonatomic) WeiboStatusID inReplyToStatusID;
@property (strong, nonatomic) WeiboGeotag * geo;
@property (assign, nonatomic) BOOL favorited;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) WeiboUserID inReplyToUserID;
@property (weak, nonatomic) NSString * inReplyToScreenname;
@property (strong, nonatomic) NSString * source;
@property (strong, nonatomic) NSString * sourceUrl;
@property (strong, nonatomic, readonly) NSURL * webLink;

@property (nonatomic, assign) BOOL treatRetweetedStatusAsQuoted;

@end
