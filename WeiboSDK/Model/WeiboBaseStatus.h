//
//  WeiboBaseStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WeiboModel.h"
#import "WeiboTextAttributes.h"

@class WeiboUser, WeiboLayoutCache, WTCallback;

@interface WeiboBaseStatus : WeiboModel {
    time_t createdAt;
    NSString * text;
    WeiboStatusID sid;
    WeiboUser * user;
        
    NSString * thumbnailPic;
    NSString * middlePic;
    NSString * originalPic;
    
    BOOL wasSeen;
    
}

@property (assign, readwrite) time_t createdAt;
@property (strong, readwrite) NSString * text;
@property (assign, readwrite) WeiboStatusID sid;
@property (strong, readwrite) WeiboUser * user;
@property (strong, readwrite) NSString * thumbnailPic;
@property (strong, readwrite) NSString * middlePic;
@property (strong, readwrite) NSString * originalPic;
@property (nonatomic, assign) BOOL quoted;
@property (weak, nonatomic, readonly) WeiboBaseStatus * quotedBaseStatus;
@property (nonatomic, strong) NSArray * pics;

@property (weak, nonatomic, readonly) NSString * displayText;
@property (nonatomic, strong, readonly) WeiboTextAttributes * textAttributes;

@property (assign, nonatomic) BOOL wasSeen;
@property (readonly, nonatomic) BOOL isComment;
@property (readonly, nonatomic) BOOL canHaveConversation;
@property (readonly, nonatomic) BOOL canReply;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, assign) BOOL isTopStatus;
@property (nonatomic, assign) BOOL isAdvertisement;
@property (nonatomic, assign) BOOL mentionedMe;
@property (nonatomic, strong) NSMutableDictionary * layoutCaches;

@property (nonatomic, assign, readonly) BOOL isDummy;
@property (nonatomic, assign, readonly) BOOL isGap;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSComparisonResult)compare:(WeiboBaseStatus *)otherStatus;

- (WeiboLayoutCache *)layoutCacheWithIdentifier:(NSString *)identifier;
- (void)removeLayoutCacheWithIdentifier:(NSString *)identifier;

- (id)_initWithDictionary:(NSDictionary *)dic;

+ (NSString *)objectsJSONKey;
+ (NSArray *)objectsWithJSON:(NSString *)json;
+ (void)parseObjectsJSON:(NSString *)json callback:(WTCallback *)callback;

@end
