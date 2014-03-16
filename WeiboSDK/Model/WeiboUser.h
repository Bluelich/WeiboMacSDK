//
//  WeiboUser.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WeiboModel.h"

@class WeiboCallback, WeiboStatus;

@interface WeiboUser : WeiboModel <NSCoding> {
    WeiboUserID userID;
    NSString * screenName;
    NSString * name;
    NSString * province;
    NSString * city;
    NSString * location;
    NSString * description;
    NSString * url;
    NSString * profileImageUrl;
    NSString * profileLargeImageUrl;
    NSString * domain;
    WeiboStatus * status;
    WeiboGender gender;
    int followersCount;
    int friendsCount;
    int statusesCount;
    int favouritesCount;
    time_t createAt;
    BOOL following;
    BOOL followMe;
    BOOL verified;
    NSTimeInterval cacheTime;
}

@property (assign, readwrite) WeiboUserID userID;
@property (strong, readwrite) NSString * screenName;
@property (strong, readwrite) NSString * name;
@property (strong, readwrite) NSString * remark;
@property (strong, readwrite) NSString * province;
@property (strong, readwrite) NSString * city;
@property (strong, readwrite) NSString * location;
@property (strong, readwrite) NSString * description;
@property (strong, readwrite) NSString * url;
@property (strong, readwrite) NSString * profileImageUrl;
@property (strong, readwrite) NSString * profileLargeImageUrl;
@property (strong, readwrite) NSString * domain;
@property (strong, readwrite) WeiboStatus * status;
@property (assign, readwrite) WeiboGender gender;
@property (assign, readwrite) int followersCount;
@property (assign, readwrite) int friendsCount;
@property (assign, readwrite) int statusesCount;
@property (assign, readwrite) int favouritesCount;
@property (assign, readwrite) time_t createAt;
@property (assign, readwrite) BOOL following;
@property (assign, readwrite) BOOL followMe;
@property (assign, readwrite) WeiboUserVerifiedType verifiedType;

@property (assign, readonly) BOOL verified;
@property (assign, readonly) BOOL isDaren;

@property (assign, nonatomic) NSTimeInterval cacheTime;

@property (assign, nonatomic) BOOL simplifiedCoding;

@end
