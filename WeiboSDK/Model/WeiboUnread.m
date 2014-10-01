//
//  WeiboUnread.m
//  Weibo
//
//  Created by Wu Tian on 12-2-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUnread.h"
#import "WeiboCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"

@implementation WeiboUnread

#pragma mark -
#pragma mark Parse Methods

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.newStatus = (NSUInteger)[dict weibo_intForKey:@"status" defaultValue:0];
        self.newStatusMentions = (NSUInteger)[dict weibo_intForKey:@"mention_status" defaultValue:0];
        self.newCommentMentions = (NSUInteger)[dict weibo_intForKey:@"mention_cmt" defaultValue:0];
        self.newComments = (NSUInteger)[dict weibo_intForKey:@"cmt" defaultValue:0];
        self.newDirectMessages = (NSUInteger)[dict weibo_intForKey:@"dm" defaultValue:0];
        self.newFollowers = (NSUInteger)[dict weibo_intForKey:@"follower" defaultValue:0];
        self.newPublicMessages = (NSUInteger)[dict weibo_intForKey:@"msgbox" defaultValue:0];
        
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Others
- (NSString *)description{
    NSMutableString * string = [NSMutableString string];
    [string appendFormat:@"\nnew status:%ld, ",self.newStatus];
    [string appendFormat:@"\nnew status mentions:%ld, ",self.newStatusMentions];
    [string appendFormat:@"\nnew comment mentions:%ld, ",self.newCommentMentions];
    [string appendFormat:@"\nnew comments:%ld, ",self.newComments];
    [string appendFormat:@"\nnew dms:%ld, ",self.newDirectMessages];
    [string appendFormat:@"\nnew followers:%ld, ",self.newFollowers];
    [string appendFormat:@"\nnew public messages:%ld. ", self.newPublicMessages];
    return string;
}

@end
