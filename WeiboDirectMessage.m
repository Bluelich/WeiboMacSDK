//
//  WeiboDirectMessage.m
//  Weibo
//
//  Created by Wutian on 13-9-2.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessage.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboDirectMessage ()
{
    struct {
        unsigned int read: 1;
    } _flags;
}

@end

@implementation WeiboDirectMessage

- (void)dealloc
{
    [_sender release], _sender = nil;
    [_recipient release], _recipient = nil;
    [_text release], _text = nil;
    
    [super dealloc];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.messageID = [dict longlongForKey:@"id" defaultValue:0];
        self.date = [dict timeForKey:@"created_at" defaultValue:0];
        self.text = [dict stringForKey:@"text" defaultValue:@""];
        self.senderID = [dict longlongForKey:@"sender_id" defaultValue:0];
        self.recipientID = [dict longlongForKey:@"recipient_id" defaultValue:0];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.messageID = [aDecoder decodeInt64ForKey:@"id"];
        self.date = [aDecoder decodeInt64ForKey:@"date"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.senderID = [aDecoder decodeInt64ForKey:@"sender_id"];
        self.recipientID = [aDecoder decodeInt64ForKey:@"recipient_id"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.messageID forKey:@"id"];
    [aCoder encodeInt64:self.date forKey:@"date"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeInt64:self.senderID forKey:@"sender_id"];
    [aCoder encodeInt64:self.recipientID forKey:@"recipient_id"];
}

- (void)setRead:(BOOL)read
{
    _flags.read = read;
}

- (BOOL)read
{
    return _flags.read;
}

- (BOOL)isEqual:(WeiboDirectMessage *)object
{
    if (object == self) return YES;
    if (![object isKindOfClass:[WeiboDirectMessage class]]) return NO;
    return object.messageID == self.messageID;
}

- (NSComparisonResult)compare:(WeiboDirectMessage *)object
{
    if (object.messageID == self.messageID) return NSOrderedSame;
    if (object.messageID > self.messageID) return NSOrderedAscending;
    return NSOrderedDescending;
}

@end
