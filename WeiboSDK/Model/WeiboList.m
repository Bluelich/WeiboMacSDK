//
//  WeiboList.m
//  Weibo
//
//  Created by Wutian on 13-7-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboList.h"
#import "WeiboAccount.h"
#import "Weibo.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboList ()

@property (nonatomic, strong) WeiboListStream * stream;
@property (nonatomic, assign) WeiboUserID decodedAccountID;

@end

@implementation WeiboList

- (void)dealloc
{
    _listID = nil;
    _name = nil;
    _mode = nil;
    _description = nil;
    _stream = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.listID = [dict stringForKey:@"idstr" defaultValue:@""];
        self.name = [dict stringForKey:@"name" defaultValue:@""];
        self.mode = [dict stringForKey:@"mode" defaultValue:@""];
        self.description = [dict stringForKey:@"description" defaultValue:@""];
        self.memberCount = [dict longlongForKey:@"member_count" defaultValue:0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        self.listID = [aDecoder decodeObjectForKey:@"idstr"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.mode = [aDecoder decodeObjectForKey:@"mode"];
        self.description = [aDecoder decodeObjectForKey:@"description"];
        self.memberCount = [aDecoder decodeInt64ForKey:@"member_count"];
        self.decodedAccountID = [aDecoder decodeInt64ForKey:@"account_id"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.listID forKey:@"idstr"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.mode forKey:@"mode"];
    [aCoder encodeObject:self.description forKey:@"description"];
    [aCoder encodeInt64:self.memberCount forKey:@"member_count"];
    [aCoder encodeInt64:self.account.user.userID forKey:@"account_id"];
}

+ (instancetype)listWithDictionary:(NSDictionary *)dict
{
    return [[[self class] alloc] initWithDictionary:dict];
}

- (BOOL)isPrivate
{
    return [self.mode isEqual:@"private"];
}

- (WeiboListStream *)stream
{
    if (!_stream)
    {
        _stream = [[WeiboListStream alloc] init];
        _stream.list = self;
        _stream.account = self.account;
    }
    return _stream;
}

- (WeiboAccount *)account
{
    if (!_account && _decodedAccountID)
    {
        self.account = [[Weibo sharedWeibo] accountWithUserID:_decodedAccountID];
        _decodedAccountID = 0;
    }
    return _account;
}

@end
