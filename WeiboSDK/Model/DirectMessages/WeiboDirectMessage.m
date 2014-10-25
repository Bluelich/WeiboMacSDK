//
//  WeiboDirectMessage.m
//  Weibo
//
//  Created by Wutian on 13-9-2.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessage.h"
#import "WeiboAccount.h"

@interface WeiboDirectMessage ()
{
    struct {
        unsigned int read: 1;
    } _flags;
}

@end

@implementation WeiboDirectMessage

+ (NSMutableArray *)ignoredCodingProperties
{
    return [@[@"attributedString"] mutableCopy];
}

+ (NSString *)defaultJSONObjectRootKey
{
    return @"direct_message";
}

+ (NSString *)defaultJSONArrayRootKey
{
    return @"direct_messages";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.messageID = [dict longLongForKey:@"id"];
        self.date = [dict timeForKey:@"created_at"];
        self.text = [dict stringForKey:@"text"] ? : @"";
        self.senderID = (WeiboUserID)[dict longLongForKey:@"sender_id"];
        self.recipientID = (WeiboUserID)[dict longLongForKey:@"recipient_id"];
        
        NSDictionary * senderDictionary = [dict objectForKey:@"sender"];
        NSDictionary * recipientDictionary = [dict objectForKey:@"recipient"];
        
        if (senderDictionary) self.sender = [WeiboUser objectWithJSONObject:senderDictionary account:self.account];
        if (recipientDictionary) self.recipient = [WeiboUser objectWithJSONObject:recipientDictionary account:self.account];
        
        return YES;
    }
    return NO;
}

- (void)setRead:(BOOL)read
{
    _flags.read = (unsigned int)read;
}

- (BOOL)read
{
    return _flags.read;
}

- (BOOL)isMine
{
    return [self.account.user isEqual:self.sender];
}

- (NSUInteger)hash
{
    return (NSUInteger)self.messageID;
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
