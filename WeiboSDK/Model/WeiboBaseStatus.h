//
//  WeiboBaseStatus.h
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

#define HIGHLIGHTED_COLOR [NSColor colorWithCalibratedRed:87.0/255.0 green:108.0/255.0 blue:121.0/255.0 alpha:1.0]
#define HASHTAG_COLOR [NSColor colorWithDeviceWhite:0.6 alpha:1.0]
#define NORMALTEXT_COLOR [NSColor colorWithDeviceWhite:0.35 alpha:1.0]

@class WTActiveTextRanges, WeiboUser;

@interface WeiboBaseStatus : NSObject {
    time_t createdAt;
    NSString * text;
    WeiboStatusID sid;
    WeiboUser * user;
    
    NSArray * activeRanges;
    NSMutableAttributedString * displayText;
    
    NSString * thumbPicURL;
    NSString * midPicURL;
    NSString * bigPicURL;
    
    BOOL wasSeen;
    
}

@property (assign, readwrite) time_t createdAt;
@property (retain, readwrite) NSString * text;
@property (assign, readwrite) WeiboStatusID sid;
@property (retain, readwrite) WeiboUser * user;
@property (assign, readwrite) NSString * thumbPicURL;
@property (assign, readwrite) NSString * midPicURL;
@property (assign, readwrite) NSString * bigPicURL;

@property (readonly, nonatomic) NSArray * activeRanges;
@property (retain, nonatomic) NSMutableAttributedString * displayText;
@property (assign, nonatomic) BOOL wasSeen;
@property (readonly, nonatomic) BOOL isComment;

- (id)initWithDictionary:(NSDictionary *)dic asRoot:(BOOL)root;
- (void)setDisplayTextWithString:(NSString *)string;
- (NSComparisonResult)compare:(WeiboBaseStatus *)otherStatus;

@end
