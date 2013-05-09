//
//  WeiboUnread.h
//  Weibo
//
//  Created by Wu Tian on 12-2-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WTCallback;

@interface WeiboUnread : NSObject {
    NSUInteger newStatus;
    NSUInteger newFollowers;
    NSUInteger newDirectMessages;
    NSUInteger newMentions;
    NSUInteger newComments;
}

@property (assign, nonatomic) NSUInteger newStatus;
@property (assign, nonatomic) NSUInteger newFollowers;
@property (assign, nonatomic) NSUInteger newDirectMessages;
@property (assign, nonatomic) NSUInteger newMentions;
@property (assign, nonatomic) NSUInteger newComments;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboUnread *)unreadWithDictionary:(NSDictionary *)dic;
+ (WeiboUnread *)unreadWithJSON:(NSString *)json;
+ (void)parseUnreadJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseUnreadJSON:(NSString *)json onComplete:(WTObjectBlock)block;
- (WeiboUnread *)initWithDictionary:(NSDictionary *)dic;

@end
