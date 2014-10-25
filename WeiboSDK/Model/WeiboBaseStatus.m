//
//  WeiboBaseStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus.h"
#import "WeiboLayoutCache.h"
#import "WeiboUser.h"
#import "WeiboCallback.h"
#import "WeiboAccount.h"
#import "JSONKit.h"

@interface WeiboBaseStatus ()

@end

@implementation WeiboBaseStatus

- (id)init
{
    if (self = [super init])
    {
        self.wasSeen = NO;
    }
    return self;
}
- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.sid = (WeiboStatusID)[dict longLongForKey:@"id"];
		self.createdAt = [dict timeForKey:@"created_at"];
        self.text = [dict stringForKey:@"text"] ? : @"";
        
        NSDictionary* userDic = [dict objectForKey:@"user"];
		if (userDic && [userDic isKindOfClass:[NSDictionary class]])
        {
			self.user = [WeiboUser objectWithJSONObject:userDic account:self.account];
		}
        return YES;
    }
    return NO;
}

+ (NSMutableArray *)ignoredCodingProperties
{
    return [@[@"layoutCaches"] mutableCopy];
}

- (NSMutableDictionary *)layoutCaches
{
    if (!_layoutCaches)
    {
        _layoutCaches = [NSMutableDictionary dictionary];
    }
    return _layoutCaches;
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
- (BOOL)isMine
{
    return [self.account.user isEqual:self.user];
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

- (NSUInteger)hash
{
    return self.sid;
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
