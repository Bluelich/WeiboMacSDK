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

@property (nonatomic, strong, readonly) NSString * text;
@property (nonatomic, strong, readonly) WTActiveTextRanges * activeRanges;
@property (nonatomic, strong, readonly) NSAttributedString * attributedString;

- (instancetype)initWithText:(NSString *)text;

@end
