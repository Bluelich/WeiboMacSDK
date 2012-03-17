//
//  WTActiveTextRanges.m
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTActiveTextRanges.h"
#import "ABActiveRange.h"
#import "RegexKitLite.h"
#import "WeiboConstants.h"

@implementation WTActiveTextRanges
@synthesize links, hashtags, usernames, activeRanges;

- (id)initWithString:(NSString *)string{
    if (self = [super init]) {
        __block NSMutableArray * linksArray = [NSMutableArray array];
        __block NSMutableArray * hashtagsArray = [NSMutableArray array];
        __block NSMutableArray * usernamesArray = [NSMutableArray array];
        __block NSMutableArray * rangesArray = [NSMutableArray array];
        [string enumerateStringsMatchedByRegex:SHORT_LINK_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            ABFlavoredRange * range = [[ABFlavoredRange alloc] init];
            [range setRangeValue:capturedRanges[0]];
            //[range setDisplayString:capturedStrings[0]];
            [range setRangeFlavor:ABActiveTextRangeFlavorURL];
            [linksArray addObject:range];
            [rangesArray addObject:range];
            [range release];
        }];
        [string enumerateStringsMatchedByRegex:MENTION_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            ABFlavoredRange * range = [[ABFlavoredRange alloc] init];
            [range setRangeValue:capturedRanges[0]];
            //[range setDisplayString:capturedStrings[1]];
            [range setRangeFlavor:ABActiveTextRangeFlavorTwitterUsername];
            [usernamesArray addObject:range];
            [rangesArray addObject:range];
            [range release];
        }];
        [string enumerateStringsMatchedByRegex:HASHTAG_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            ABFlavoredRange * range = [[ABFlavoredRange alloc] init];
            [range setRangeValue:capturedRanges[0]];
            //[range setDisplayString:capturedStrings[1]];
            [range setRangeFlavor:ABActiveTextRangeFlavorTwitterHashtag];
            [hashtagsArray addObject:range];
            [rangesArray addObject:range];
            [range release];
        }];
        links = [[NSArray alloc] initWithArray:linksArray];
        hashtags = [[NSArray alloc] initWithArray:hashtagsArray];
        usernames = [[NSArray alloc] initWithArray:usernamesArray];
        activeRanges = [[NSArray alloc] initWithArray:rangesArray];
        [NSString clearStringCache];
    }
    return self;
}

- (void)dealloc{
    [links release]; links = nil;
    [hashtags release]; hashtags = nil;
    [usernames release]; usernames = nil;
    [activeRanges release]; activeRanges = nil;
    [super dealloc];
}

@end
