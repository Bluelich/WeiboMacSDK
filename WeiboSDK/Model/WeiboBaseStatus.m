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
#import "WeiboCallback.h"
#import "JSONKit.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboBaseStatus ()

@property (nonatomic, strong) WeiboAttributedString * attributedString;

@end

@implementation WeiboBaseStatus

- (id)init
{
    if (self = [super init])
    {
        self.wasSeen = NO;
        self.layoutCaches = [NSMutableDictionary dictionary];
    }
    return self;
}
- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.sid = [dict longlongForKey:@"id" defaultValue:-1];
		self.createdAt = [dict timeForKey:@"created_at" defaultValue:0];
		self.text = [dict stringForKey:@"text" defaultValue:@""];
        
        NSDictionary* userDic = [dict objectForKey:@"user"];
		if (userDic && [userDic isKindOfClass:[NSDictionary class]])
        {
			self.user = [WeiboUser objectWithJSONObject:userDic];
		}
        return YES;
    }
    return NO;
}
- (id)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super initWithJSONDictionary:dict])
    {
        self.attributedString = [WeiboAttributedString stringWithString:self.displayPlainText];
        
        if (!self.quoted && self.quotedBaseStatus)
        {
            self.quotedBaseStatus.attributedString = [WeiboAttributedString stringWithString:self.quotedBaseStatus.displayPlainText];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.attributedString = [WeiboAttributedString stringWithString:self.displayPlainText];
    }
    return self;
}

+ (NSMutableArray *)ignoredCodingProperties
{
    return [@[@"attributedString",
               @"displayPlainText",
               @"layoutCaches"] mutableCopy];
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

- (NSString *)displayPlainText
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
        cache = [[WeiboLayoutCache alloc] init];
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

+ (NSString *)defaultJSONArrayRootKey
{
    return @"statuses";
}
+ (NSString *)defaultJSONObjectRootKey
{
    return @"status";
}

@end
