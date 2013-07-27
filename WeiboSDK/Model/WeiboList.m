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

@property (nonatomic, retain) WeiboListStream * stream;

@end

@implementation WeiboList

- (void)dealloc
{
    [_listID release], _listID = nil;
    [_name release], _name = nil;
    [_mode release], _mode = nil;
    [_description release], _description = nil;
    [_stream release], _stream = nil;
    [super dealloc];
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
    return [[[[self class] alloc] initWithDictionary:dict] autorelease];
}

- (BOOL)isPrivate
{
    return [self.mode isEqual:@"private"];
}

@end
