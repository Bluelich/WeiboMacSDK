//
//  WeiboTextAttributes.h
//  Weibo
//
//  Created by Wutian on 14-2-16.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTActiveTextRanges;

@interface WeiboTextAttributes : NSObject

@property (nonatomic, retain, readonly) NSString * text;
@property (nonatomic, retain, readonly) WTActiveTextRanges * activeRanges;
@property (nonatomic, retain, readonly) NSAttributedString * attributedString;

- (instancetype)initWithText:(NSString *)text;

@end
