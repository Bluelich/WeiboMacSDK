//
//  WeiboList.m
//  Weibo
//
//  Created by Wutian on 13-7-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboList.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboList ()

@property (nonatomic, strong) WeiboListStream * stream;

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

@end
