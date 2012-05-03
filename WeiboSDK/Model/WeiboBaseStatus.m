//
//  WeiboBaseStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus.h"
#import "WTActiveTextRanges.h"
#import "ABActiveRange.h"

@implementation WeiboBaseStatus
@synthesize createdAt, text, sid, activeRanges, displayText, user;
@synthesize thumbPicURL, bigPicURL, midPicURL;
@synthesize wasSeen, isComment;

- (id)init{
    if (self = [super init]) {
        wasSeen = NO;
    }
    return self;
}
- (id)_initWithDictionary:(NSDictionary *)dic{
    return [self init];
}
- (id)initWithDictionary:(NSDictionary *)dic asRoot:(BOOL)root{
    WeiboBaseStatus * status = [self _initWithDictionary:dic];
    if (root) {
        [status _setUpDisplayText];
    }
    return status;
}
- (void)_setUpDisplayText{
    // sub-class should implement.
}

- (void)dealloc{
    [text release]; text = nil;
    [activeRanges release]; activeRanges = nil;
    [displayText release]; displayText = nil;
    [user release]; user = nil;
    [super dealloc];
}

- (void)setDisplayTextWithString:(NSString *)string{
    WTActiveTextRanges * ranges = [[WTActiveTextRanges alloc] initWithString:string];
    
    NSMutableAttributedString * display = [[NSMutableAttributedString alloc] initWithString:string];
    NSColor * color = [NSColor colorWithDeviceRed:0.25 green:0.25
                                             blue:0.25 alpha:1.0];
    [display addAttribute:NSForegroundColorAttributeName 
                    value:color range:NSMakeRange(0, [display length])];
    for (ABFlavoredRange * range in ranges.activeRanges) {
        NSColor * fontColor = HIGHLIGHTED_COLOR;
        if (range.rangeFlavor == ABActiveTextRangeFlavorTwitterHashtag) {
            fontColor = HASHTAG_COLOR;
        }
        NSDictionary * linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                    fontColor, NSForegroundColorAttributeName,nil];
        [display addAttributes:linkAttr range:range.rangeValue];
    }
    self.displayText = display;
    [display release];
    
    activeRanges = [ranges.activeRanges retain];
    [ranges release];
}

- (NSComparisonResult)compare:(WeiboBaseStatus *)otherStatus{
    if (self.sid == otherStatus.sid) {
        return NSOrderedSame;
    }else if (self.sid < otherStatus.sid){
        return NSOrderedAscending;
    }else{
        return NSOrderedDescending;
    }
}

- (BOOL)isComment{
    return NO;
}

@end
