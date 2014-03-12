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
#import "WTCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "NSObject+AssociatedObject.h"
#import "JSONKit.h"

@implementation WeiboComment
@synthesize replyToStatus, replyToComment;


#pragma mark -
#pragma mark Parse Methods
+ (WeiboComment *)commentWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}
+ (WeiboComment *)commentWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    WeiboComment * comment = [WeiboComment commentWithDictionary:dictionary];
    return comment;
}
+ (NSString *)objectsJSONKey
{
    return @"comments";
}
+ (void)parseCommentsJSON:(NSString *)json callback:(WTCallback *)callback{
    [self parseObjectsJSON:json callback:callback];
}
+ (void)parseCommentJSON:(NSString *)json callback:(WTCallback *)callback{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        WeiboComment * comment = [self commentWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:comment];
        });
    });
}

- (id)_initWithDictionary:(NSDictionary *)dic
{
    if ((self = [super _initWithDictionary:dic]))
    {
        
        self.treatReplyingStatusAsQuoted = YES;
        self.treatReplyingCommentAsQuoted = YES;
        
		NSDictionary* statusDic = [dic objectForKey:@"status"];
        WeiboStatus * status = [[WeiboStatus alloc] initWithDictionary:statusDic];
		if (statusDic)
        {
			self.replyToStatus = status;
            self.replyToStatus.quoted = YES;
		}

        NSDictionary* commentDic = [dic objectForKey:@"reply_comment"];
        if (commentDic) {
            WeiboComment * comment = [[WeiboComment alloc] initWithDictionary:commentDic];
            self.replyToComment = comment;
            self.replyToComment.quoted = YES;
        }
    }
    return self;
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
