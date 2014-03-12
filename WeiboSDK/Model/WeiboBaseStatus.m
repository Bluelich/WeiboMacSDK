//
//  WeiboBaseStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus.h"
#import "ABActiveRange.h"
#import "WeiboLayoutCache.h"
#import "WeiboUser.h"
#import "WTCallback.h"
#import "JSONKit.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboBaseStatus ()

@property (nonatomic, retain) WeiboTextAttributes * textAttributes;

@end

@implementation WeiboBaseStatus
@synthesize createdAt, text, sid, user;
@synthesize thumbnailPic, originalPic, middlePic;
@synthesize wasSeen, isComment;
@synthesize quoted = _quoted;

- (void)dealloc
{
    [text release]; text = nil;
    [user release], user = nil;
    [_layoutCaches release], _layoutCaches = nil;
    [thumbnailPic release], thumbnailPic = nil;
    [middlePic release], middlePic = nil;
    [originalPic release], originalPic = nil;
    [_pics release], _pics = nil;
    [_textAttributes release], _textAttributes = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        wasSeen = NO;
        self.layoutCaches = [NSMutableDictionary dictionary];
    }
    return self;
}
- (id)_initWithDictionary:(NSDictionary *)dic
{
    if (self = [self init])
    {
        self.sid = [dic longlongForKey:@"id" defaultValue:-1];
		self.createdAt = [dic timeForKey:@"created_at" defaultValue:0];
		self.text = [dic stringForKey:@"text" defaultValue:@""];
        
        NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic && [userDic isKindOfClass:[NSDictionary class]])
        {
			self.user = [WeiboUser userWithDictionary:userDic];
		}
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [self _initWithDictionary:dic];
    if (self)
    {
        self.textAttributes = [[[WeiboTextAttributes alloc] initWithText:self.displayText] autorelease];
        
        if (!self.quoted && self.quotedBaseStatus)
        {
            self.quotedBaseStatus.textAttributes = [[[WeiboTextAttributes alloc] initWithText:self.quotedBaseStatus.displayText] autorelease];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.textAttributes = [[[WeiboTextAttributes alloc] initWithText:self.displayText] autorelease];
    }
    return self;
}

+ (NSMutableArray *)ignoredCodingProperties
{
    return [[@[@"textAttributes",
               @"displayText",
               @"layoutCaches"] mutableCopy] autorelease];
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

- (BOOL)isComment
{
    return NO;
}
- (BOOL)canHaveConversation
{
    return NO;
}
- (BOOL)canReply
{
    return YES;
}

- (WeiboBaseStatus *)quotedBaseStatus
{
    return nil;
}

- (NSString *)displayText
{
    if (self.quoted)
    {
        if (self.user.screenName)
        {
            return [NSString stringWithFormat:@"@%@:%@",self.user.screenName, self.text];
        }
        else
        {
            return self.text;
        }
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

- (BOOL)isDummy
{
    return NO;
}

- (BOOL)isGap
{
    return NO;
}

+ (NSString *)objectsJSONKey
{
    return @"statuses";
}

+ (NSArray *)objectsWithJSON:(NSString *)json
{
    NSDictionary * jsonObject = [json objectFromJSONString];
    NSArray * dictionaries = [jsonObject objectForKey:[self objectsJSONKey]];
    
    NSMutableArray * statuses = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries)
    {
        WeiboBaseStatus * status = [[[self class] alloc] initWithDictionary:dic];
        [statuses addObject:status];
    }
    
    return statuses;
}
+ (void)parseObjectsJSON:(NSString *)json callback:(WTCallback *)callback
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSArray * statuses = [self objectsWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:statuses];
        });
    });
}

@end
