//
//  WeiboBaseStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WTActiveTextRanges, WeiboUser, WeiboLayoutCache;

@interface WeiboBaseStatus : NSObject {
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
@property (retain, readwrite) NSString * text;
@property (assign, readwrite) WeiboStatusID sid;
@property (retain, readwrite) WeiboUser * user;
@property (retain, readwrite) NSString * thumbnailPic;
@property (retain, readwrite) NSString * middlePic;
@property (retain, readwrite) NSString * originalPic;
@property (nonatomic, assign) BOOL quoted;
@property (nonatomic, readonly) WeiboBaseStatus * quotedBaseStatus;
@property (nonatomic, retain) NSArray * pics;

@property (nonatomic, readonly) NSString * displayText;
@property (retain, nonatomic) WTActiveTextRanges * activeRanges;

@property (assign, nonatomic) BOOL wasSeen;
@property (readonly, nonatomic) BOOL isComment;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, retain) NSMutableDictionary * layoutCaches;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSComparisonResult)compare:(WeiboBaseStatus *)otherStatus;

- (WeiboLayoutCache *)layoutCacheWithIdentifier:(NSString *)identifier;
- (void)removeLayoutCacheWithIdentifier:(NSString *)identifier;

@end
