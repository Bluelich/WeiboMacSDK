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

@interface WeiboBaseStatus ()

@property (nonatomic, retain) NSMutableDictionary * layoutCaches;

@end

@implementation WeiboBaseStatus
@synthesize createdAt, text, sid, user;
@synthesize thumbnailPic, originalPic, middlePic;
@synthesize wasSeen, isComment;
@synthesize activeRanges = _activeRanges;
@synthesize quoted = _quoted;

- (void)dealloc{
    [text release]; text = nil;
    [_activeRanges release]; _activeRanges = nil;
    [user release]; user = nil;
    [_layoutCaches release], _layoutCaches = nil;
    [thumbnailPic release]; thumbnailPic = nil;
    [middlePic release]; middlePic = nil;
    [originalPic release]; originalPic = nil;
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        wasSeen = NO;
        self.layoutCaches = [NSMutableDictionary dictionary];
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

- (WeiboLayoutCache *)layoutCacheWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    WeiboLayoutCache * cache = self.layoutCaches[identifier];
    if (!cache)
    {
        cache = [[[WeiboLayoutCache alloc] init] autorelease];
        self.layoutCaches[identifier] = cache;
    }
    return cache;
}

- (void)removeLayoutCacheWithIdentifier:(NSString *)identifier
{
    if (identifier)
    {
        [self.layoutCaches removeObjectForKey:identifier];
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (![object isKindOfClass:[WeiboBaseStatus class]])
    {
        return NO;
    }
    
    if (self.sid == [object sid])
    {
        return YES;
    }
    
    return NO;
}

@end
