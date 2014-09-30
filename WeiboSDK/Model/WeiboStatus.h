//
//  WeiboStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WeiboBaseStatus.h"

@class WeiboUser, WeiboCallback;

@interface WeiboStatus : WeiboBaseStatus {
    BOOL truncated;
    WeiboStatus * retweetedStatus;
    WeiboStatusID inReplyToStatusID;
    BOOL favorited;
    WeiboUserID inReplyToUserID;
    NSString * __weak inReplyToScreenname;
    NSString * source;
    NSString * sourceUrl;
}

@property (assign, nonatomic) BOOL truncated;
@property (strong, atomic) WeiboStatus * retweetedStatus;
@property (assign, nonatomic) WeiboStatusID inReplyToStatusID;
@property (assign, nonatomic) BOOL favorited;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) WeiboUserID inReplyToUserID;
@property (weak, nonatomic) NSString * inReplyToScreenname;
@property (strong, nonatomic) NSString * source;
@property (strong, nonatomic) NSString * sourceUrl;
@property (strong, nonatomic, readonly) NSURL * webLink;
@property (assign, nonatomic, readonly) CLLocationCoordinate2D geoCoordinate;

@property (nonatomic, assign) BOOL treatRetweetedStatusAsQuoted;

@end
