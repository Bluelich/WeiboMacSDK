//
//  WeiboUnread.m
//  Weibo
//
//  Created by Wu Tian on 12-2-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUnread.h"
#import "WeiboCallback.h"
#import "JSONKit.h"

@implementation WeiboUnread

#pragma mark -
#pragma mark Parse Methods

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.newStatus = (NSUInteger)[dict intForKey:@"status"];
        self.newStatusMentions = (NSUInteger)[dict intForKey:@"mention_status"];
        self.newCommentMentions = (NSUInteger)[dict intForKey:@"mention_cmt"];
        self.newComments = (NSUInteger)[dict intForKey:@"cmt"];
        self.newDirectMessages = (NSUInteger)[dict intForKey:@"dm"];
        self.newFollowers = (NSUInteger)[dict intForKey:@"follower"];
        self.newPublicMessages = (NSUInteger)[dict intForKey:@"msgbox"];
        
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
