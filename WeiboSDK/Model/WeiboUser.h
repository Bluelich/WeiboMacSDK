//
//  WeiboUser.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WTCallback, WeiboStatus;

@interface WeiboUser : NSObject <NSCoding> {
    WeiboUserID userID;
    NSString * screenName;
    NSString * name;
    NSString * province;
    NSString * city;
    NSString * location;
    NSString * description;
    NSString * url;
    NSString * profileImageUrl;
    NSString * domain;
    WeiboStatus * status;
    WeiboGender gender;
    int followersCount;
    int friendsCount;
    int statusesCount;
    int favouritesCount;
    time_t createAt;
    BOOL following;
    BOOL verified;
}

@property (assign, readwrite) WeiboUserID userID;
@property (retain, readwrite) NSString * screenName;
@property (retain, readwrite) NSString * name;
@property (retain, readwrite) NSString * province;
@property (retain, readwrite) NSString * city;
@property (retain, readwrite) NSString * location;
@property (retain, readwrite) NSString * description;
@property (retain, readwrite) NSString * url;
@property (retain, readwrite) NSString * profileImageUrl;
@property (retain, readwrite) NSString * domain;
@property (retain, readwrite) WeiboStatus * status;
@property (assign, readwrite) WeiboGender gender;
@property (assign, readwrite) int followersCount;
@property (assign, readwrite) int friendsCount;
@property (assign, readwrite) int statusesCount;
@property (assign, readwrite) int favouritesCount;
@property (assign, readwrite) time_t createAt;
@property (assign, readwrite) BOOL following;
@property (assign, readwrite) BOOL verified;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboUser *)userWithDictionary:(NSDictionary *)dic;
+ (WeiboUser *)userWithJSON:(NSString *)json;
+ (NSArray *)usersWithJSON:(NSString *)json;
+ (void)parseUserJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseUsersJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseUserJSON:(NSString *)json onComplete:(WTObjectBlock)block;
+ (void)parseUsersJSON:(NSString *)json onComplete:(WTArrayBlock)block;
- (WeiboUser *)initWithDictionary:(NSDictionary *)dic;

@end
