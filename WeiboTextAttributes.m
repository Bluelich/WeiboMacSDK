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

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) WTActiveTextRanges * activeRanges;

@end

@implementation WeiboTextAttributes

- (void)dealloc
{
    [_text release], _text = nil;
    [_activeRanges release], _activeRanges = nil;
    [_attributedString release], _attributedString = nil;
    [super dealloc];
}

- (instancetype)initWithText:(NSString *)text
{
    if (self = [self init])
    {
        self.text = text;
        self.activeRanges = [[[WTActiveTextRanges alloc] initWithString:text] autorelease];
    }
    return self;
}

@end
