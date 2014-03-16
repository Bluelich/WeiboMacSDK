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
@synthesize newStatus, newStatusMentions, newCommentMentions, newComments, newDirectMessages, newFollowers;

#pragma mark -
#pragma mark Parse Methods

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.newStatus = [dict intForKey:@"status" defaultValue:0];
        self.newStatusMentions = [dict intForKey:@"mention_status" defaultValue:0];
        self.newCommentMentions = [dict intForKey:@"mention_cmt" defaultValue:0];
        self.newComments = [dict intForKey:@"cmt" defaultValue:0];
        self.newDirectMessages = [dict intForKey:@"dm" defaultValue:0];
        self.newFollowers = [dict intForKey:@"follower" defaultValue:0];
    
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
    [string appendFormat:@"\nnew followers:%ld. ",self.newFollowers];
    return string;
}

@end
