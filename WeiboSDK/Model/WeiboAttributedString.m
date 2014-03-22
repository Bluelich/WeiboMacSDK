//
//  WeiboAttributedString.m
//  Weibo
//
//  Created by Wutian on 14-3-21.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboAttributedString.h"
#import <RegexKitLite/RegexKitLite.h>

NSString * const WeiboAttributedStringActiveRangeKey = @"WeiboAttributedStringActiveRangeKey";
NSString * const WeiboAttributedStringAttachmentTypeKey = @"WeiboAttributedStringAttachmentTypeKey";

@implementation WeiboAttributedString

+ (instancetype)stringWithString:(NSString *)string
{
    if (!string) return nil;
    
    WeiboAttributedString * attributedString = (WeiboAttributedString *)[[NSMutableAttributedString alloc] initWithString:string];
    
    [string enumerateStringsMatchedByRegex:SHORT_LINK_REGEX usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        [attributedString addAttribute:WeiboAttributedStringActiveRangeKey value:@(WeiboAttributedStringRangeFlavorURL) range:capturedRanges[0]];
    }];
    [string enumerateStringsMatchedByRegex:MENTION_REGEX usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        [attributedString addAttribute:WeiboAttributedStringActiveRangeKey value:@(WeiboAttributedStringRangeFlavorUsername) range:capturedRanges[0]];
    }];
    [string enumerateStringsMatchedByRegex:HASHTAG_REGEX usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        [attributedString addAttribute:WeiboAttributedStringActiveRangeKey value:@(WeiboAttributedStringRangeFlavorHashtag) range:capturedRanges[0]];
    }];
    [string enumerateStringsMatchedByRegex:EMOTICON_REGEX usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        [attributedString addAttribute:WeiboAttributedStringAttachmentTypeKey value:@(WeiboAttributedStringAttachmentTypeEmoticon) range:capturedRanges[0]];
    }];
    
    return attributedString;
}

@end

@implementation NSAttributedString (WeiboAttributedString)

- (void)enumerateActiveRanges:(void (^)(WeiboAttributedStringRangeFlavor rangeFlavor, NSRange range, BOOL *stop))block
{
    if (!block) return;
    
    [self enumerateAttribute:WeiboAttributedStringActiveRangeKey inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        block([value integerValue], range, stop);
    }];
}

- (WeiboAttributedStringRangeFlavor)rangeFlavorAtIndex:(NSInteger)index
{
    return [self rangeFlavorAtIndex:index effectiveRange:NULL];
}

- (WeiboAttributedStringRangeFlavor)rangeFlavorAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)effectiveRange
{
    return [[self attribute:WeiboAttributedStringActiveRangeKey atIndex:index effectiveRange:effectiveRange] integerValue];
}

- (void)enumerateAttachments:(void (^)(WeiboAttributedStringAttachmentType attachmentType, NSRange range, BOOL *stop))block
{
    if (!block) return;
    
    [self enumerateAttribute:WeiboAttributedStringAttachmentTypeKey inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        block([value integerValue], range, stop);
    }];
}
- (WeiboAttributedStringAttachmentType)attachmentTypeAtIndex:(NSInteger)index
{
    return [self attachmentTypeAtIndex:index effectiveRange:NULL];
}
- (WeiboAttributedStringAttachmentType)attachmentTypeAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)effectiveRange
{
    return [[self attribute:WeiboAttributedStringAttachmentTypeKey atIndex:index effectiveRange:effectiveRange] integerValue];
}

@end
