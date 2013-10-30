//
//  WeiboUnread.m
//  Weibo
//
//  Created by Wu Tian on 12-2-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUnread.h"
#import "WTCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"

@implementation WeiboUnread
@synthesize newStatus, newStatusMentions, newCommentMentions, newComments, newDirectMessages, newFollowers;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboUnread *)unreadWithDictionary:(NSDictionary *)dic{
    return [[[WeiboUnread alloc] initWithDictionary:dic] autorelease];
}
+ (WeiboUnread *)unreadWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    return [WeiboUnread unreadWithDictionary:dictionary];
}
+ (void)parseUnreadJSON:(NSString *)json callback:(WTCallback *)callback{
    [self parseUnreadJSON:json onComplete:^(id object) {
        [callback invoke:json];
    }];
}
+ (void)parseUnreadJSON:(NSString *)json onComplete:(WTObjectBlock)block{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        WeiboUnread * unread = [self unreadWithJSON:json];
        [json release];
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(unread);
        });
    });
}
- (WeiboUnread *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.newStatus = [dic intForKey:@"status" defaultValue:0];
        self.newStatusMentions = [dic intForKey:@"mention_status" defaultValue:0];
        self.newCommentMentions = [dic intForKey:@"mention_cmt" defaultValue:0];
        self.newComments = [dic intForKey:@"cmt" defaultValue:0];
        self.newDirectMessages = [dic intForKey:@"dm" defaultValue:0];
        self.newFollowers = [dic intForKey:@"follower" defaultValue:0];
    }
    return self;
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
