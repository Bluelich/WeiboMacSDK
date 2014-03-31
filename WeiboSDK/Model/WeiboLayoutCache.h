//
//  WeiboLayoutCache.h
//  Weibo
//
//  Created by 吴 天 on 12-11-25.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboLayoutCache : NSObject

// Settings
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) BOOL fontSize;
@property (nonatomic, assign) BOOL showThumb;
@property (nonatomic, assign) BOOL placeThumbOnSide;

// Derived
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CGFloat textHeightOfQuotedStatus;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGRect avatarFrame;
@property (nonatomic, assign) CGRect textFrame;
@property (nonatomic, assign) CGRect quotedTextFrame;
@property (nonatomic, assign) CGRect quoteLineFrame;
@property (nonatomic, assign) CGRect imageContentViewFrame;

@property (nonatomic, strong) NSAttributedString * attributedString;

@end
