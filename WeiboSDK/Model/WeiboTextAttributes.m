//
//  WeiboTextAttributes.m
//  Weibo
//
//  Created by Wutian on 14-2-16.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboTextAttributes.h"
#import "WTActiveTextRanges.h"

@interface WeiboTextAttributes ()

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) WTActiveTextRanges * activeRanges;

@end

@implementation WeiboTextAttributes

- (void)dealloc
{
    _text = nil;
    _activeRanges = nil;
    _attributedString = nil;
}

- (instancetype)initWithText:(NSString *)text
{
    if (self = [self init])
    {
        self.text = text;
        self.activeRanges = [[WTActiveTextRanges alloc] initWithString:text];
    }
    return self;
}

@end
