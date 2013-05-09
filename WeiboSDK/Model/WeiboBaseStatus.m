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
#import "WeiboLayoutCache.h"
#import "WeiboUser.h"

@implementation WeiboBaseStatus
@synthesize createdAt, text, sid, user;
@synthesize thumbnailPic, originalPic, middlePic;
@synthesize wasSeen, isComment;
@synthesize activeRanges = _activeRanges;
@synthesize layoutCache = _layoutCache;
@synthesize quoted = _quoted;

- (void)dealloc{
    [text release]; text = nil;
    [_activeRanges release]; _activeRanges = nil;
    [user release]; user = nil;
    [_layoutCache release], _layoutCache = nil;
    [thumbnailPic release]; thumbnailPic = nil;
    [middlePic release]; middlePic = nil;
    [originalPic release]; originalPic = nil;
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        wasSeen = NO;
        self.layoutCache = [[[WeiboLayoutCache alloc] init] autorelease];
    }
    return self;
}
- (id)_initWithDictionary:(NSDictionary *)dic{
    return [self init];
}
- (id)initWithDictionary:(NSDictionary *)dic{
    if ([self _initWithDictionary:dic])
    {
        self.activeRanges = [[[WTActiveTextRanges alloc] initWithString:self.displayText] autorelease];
        if (!self.quoted && self.quotedBaseStatus)
        {
            self.quotedBaseStatus.activeRanges = [[[WTActiveTextRanges alloc] initWithString:self.quotedBaseStatus.displayText] autorelease];
        }
    }
    return self;
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

- (WeiboBaseStatus *)quotedBaseStatus
{
    return nil;
}

- (NSString *)displayText
{
    if (self.quoted)
    {
        return [NSString stringWithFormat:@"@%@:%@",self.user.screenName, self.text];
    }
    
    return self.text;
}

@end
