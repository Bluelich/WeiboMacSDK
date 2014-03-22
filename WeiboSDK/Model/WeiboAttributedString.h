//
//  WeiboAttributedString.h
//  Weibo
//
//  Created by Wutian on 14-3-21.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WeiboAttributedStringRangeFlavor)
{
    WeiboAttributedStringRangeFlavorNone = 0,
    WeiboAttributedStringRangeFlavorURL,
    WeiboAttributedStringRangeFlavorUsername,
    WeiboAttributedStringRangeFlavorHashtag,
};

typedef NS_ENUM(NSInteger, WeiboAttributedStringAttachmentType)
{
    WeiboAttributedStringAttachmentTypeNone = 0,
    WeiboAttributedStringAttachmentTypeEmoticon,
};

extern NSString * const WeiboAttributedStringActiveRangeKey;
extern NSString * const WeiboAttributedStringAttachmentTypeKey;

@interface WeiboAttributedString : NSMutableAttributedString

+ (instancetype)stringWithString:(NSString *)string;

- (void)enumerateActiveRanges:(void (^)(WeiboAttributedStringRangeFlavor rangeFlavor, NSRange range, BOOL *stop))block;
- (WeiboAttributedStringRangeFlavor)rangeFlavorAtIndex:(NSInteger)index;
- (WeiboAttributedStringRangeFlavor)rangeFlavorAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)effectiveRange;

- (void)enumerateAttachments:(void (^)(WeiboAttributedStringAttachmentType attachmentType, NSRange range, BOOL *stop))block;
- (WeiboAttributedStringAttachmentType)attachmentTypeAtIndex:(NSInteger)index;
- (WeiboAttributedStringAttachmentType)attachmentTypeAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)effectiveRange;

@end
