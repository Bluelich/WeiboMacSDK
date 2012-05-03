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
#import "JSONKit.h"

static BOOL shouldMakeFullDisplayText = YES;

@implementation WeiboComment
@synthesize replyToStatus, replyToComment;

- (void)dealloc{
    self.replyToStatus = nil;
    self.replyToComment = nil;
    [super dealloc];
}

+ (void)setShouldMakeFullDisplayText:(BOOL)full{
    shouldMakeFullDisplayText = full;
}

#pragma mark -
#pragma mark Parse Methods
+ (WeiboComment *)commentWithDictionary:(NSDictionary *)dic{
    return [[[WeiboComment alloc] initWithDictionary:dic asRoot:YES] autorelease];
}
+ (WeiboComment *)commentWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    WeiboComment * comment = [WeiboComment commentWithDictionary:dictionary];
    return comment;
}
+ (NSArray *)commentsWithJSON:(NSString *)json{
    NSArray * dictionaries = [json objectFromJSONString];
    NSMutableArray * comments = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboComment * comment = [WeiboComment commentWithDictionary:dic];
        [comments addObject:comment];
    }
    return comments;
}
+ (void)parseCommentsJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSArray * comments = [self commentsWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:comments];
            [json release];
        });
    });
}
+ (void)parseCommentJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        WeiboComment * comment = [self commentWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:comment];
            [json release];
        });
    });
}

- (id)_initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.sid = [dic longlongForKey:@"id" defaultValue:-1];
		self.createdAt = [dic timeForKey:@"created_at" defaultValue:0];
		self.text = [dic stringForKey:@"text" defaultValue:@""];
        
        NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic) {
			self.user = [WeiboUser userWithDictionary:userDic];
		}
		NSDictionary* statusDic = [dic objectForKey:@"status"];
		if (shouldMakeFullDisplayText && statusDic) {
            WeiboStatus * status = [[WeiboStatus alloc] initWithDictionary:statusDic asRoot:NO];
			self.replyToStatus = status;
            [status release];
		}
        NSDictionary* commentDic = [dic objectForKey:@"reply_comment"];
        if (shouldMakeFullDisplayText && commentDic) {
            WeiboComment * comment = [[WeiboComment alloc] initWithDictionary:commentDic asRoot:NO];
            self.replyToComment = comment;
            [comment release];
        }
        if (replyToStatus) {
            self.thumbPicURL = replyToStatus.thumbPicURL;
            self.midPicURL = replyToStatus.midPicURL;
            self.bigPicURL = replyToStatus.bigPicURL;
        }
    }
    return self;
}

- (void)_setUpDisplayText{
    NSMutableString * string = [NSMutableString stringWithString:text];
    if (replyToComment) {
        [string appendFormat:@"\n\n// @%@:",replyToComment.user.name];
        [string appendString:replyToComment.text];
    }else if (replyToStatus) {
        [string appendFormat:@"\n\n// @%@:",replyToStatus.user.name];
        [string appendString:replyToStatus.text];
    }
    [self setDisplayTextWithString:string];
}

- (BOOL)isComment{
    return YES;
}

@end
