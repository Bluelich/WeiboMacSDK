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

@property (nonatomic, assign, readwrite) WeiboUserID userID;
@property (nonatomic, strong, readwrite) NSString * screenName;
@property (nonatomic, strong, readwrite) NSString * name;
@property (nonatomic, strong, readwrite) NSString * remark;
@property (nonatomic, strong, readwrite) NSString * province;
@property (nonatomic, strong, readwrite) NSString * city;
@property (nonatomic, strong, readwrite) NSString * location;
@property (nonatomic, strong, readwrite) NSString * description;
@property (nonatomic, strong, readwrite) NSString * url;
@property (nonatomic, strong, readwrite) NSString * profileImageUrl;
@property (nonatomic, strong, readwrite) NSString * profileLargeImageUrl;
@property (nonatomic, strong, readwrite) NSString * domain;
@property (nonatomic, strong, readwrite) WeiboStatus * status;
@property (nonatomic, assign, readwrite) WeiboGender gender;
@property (nonatomic, assign, readwrite) int followersCount;
@property (nonatomic, assign, readwrite) int friendsCount;
@property (nonatomic, assign, readwrite) int statusesCount;
@property (nonatomic, assign, readwrite) int favouritesCount;
@property (nonatomic, assign, readwrite) time_t createAt;
@property (nonatomic, assign, readwrite) BOOL following;
@property (nonatomic, assign, readwrite) BOOL followMe;
@property (nonatomic, assign, readwrite) WeiboUserVerifiedType verifiedType;
@property (nonatomic, strong, readwrite) NSString * verifiedReason;

@property (nonatomic, assign, readonly) BOOL verified;
@property (nonatomic, assign, readonly) BOOL isDaren;

@property (assign, nonatomic) NSTimeInterval cacheTime;

@property (assign, nonatomic) BOOL simplifiedCoding;

@end
