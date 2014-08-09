//
//  WeiboBaseStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"

@class WeiboUser, WeiboLayoutCache, WeiboCallback;

@interface WeiboBaseStatus : WeiboModel

@property (nonatomic, assign) time_t createdAt;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) WeiboStatusID sid;
@property (nonatomic, strong) WeiboUser * user;
@property (nonatomic, strong) NSString * thumbnailPic;
@property (nonatomic, strong) NSString * middlePic;
@property (nonatomic, strong) NSString * originalPic;
@property (nonatomic, assign) BOOL quoted;
@property (nonatomic, strong, readonly) WeiboBaseStatus * quotedBaseStatus;
@property (nonatomic, strong) NSArray * pics;

@property (nonatomic, readonly) NSString * displayPlainText;

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

- (NSComparisonResult)compare:(WeiboBaseStatus *)otherStatus;

- (WeiboLayoutCache *)layoutCacheWithIdentifier:(NSString *)identifier;
- (void)removeLayoutCacheWithIdentifier:(NSString *)identifier;

@end
