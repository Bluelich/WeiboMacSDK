//
//  WeiboComment.m
//  Weibo
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboComment.h"
#import "WeiboStatus.h"
#import "WeiboUser.h"
#import "WeiboCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "NSObject+AssociatedObject.h"
#import "JSONKit.h"

@implementation WeiboComment
@synthesize replyToStatus, replyToComment;


#pragma mark -
#pragma mark Parse Methods

+ (NSString *)defaultJSONArrayRootKey
{
    return @"comments";
}
+ (NSString *)defaultJSONObjectRootKey
{
    return @"comment";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        
        self.treatReplyingStatusAsQuoted = YES;
        self.treatReplyingCommentAsQuoted = YES;
        
		NSDictionary* statusDic = [dict objectForKey:@"status"];
		if (statusDic)
        {
			self.replyToStatus = [WeiboStatus objectWithJSONObject:statusDic];
            self.replyToStatus.quoted = YES;
		}

        NSDictionary* commentDic = [dict objectForKey:@"reply_comment"];
        if (commentDic)
        {
            WeiboComment * comment = [WeiboComment objectWithJSONObject:commentDic];
            self.replyToComment = comment;
            self.replyToComment.quoted = YES;
        }
        return YES;
    }
    return NO;
}

- (BOOL)isComment
{
    return YES;
}
- (BOOL)canHaveConversation
{
    return YES;
}

- (WeiboBaseStatus *)quotedBaseStatus
{
    if (self.replyToComment && self.treatReplyingCommentAsQuoted)
    {
        return self.replyToComment;
    }
    else if (self.replyToStatus && self.treatReplyingStatusAsQuoted)
    {
        return self.replyToStatus;
    }
    return nil;
}

@end
