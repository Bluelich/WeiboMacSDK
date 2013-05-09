//
//  WeiboComment.h
//  Weibo
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboBaseStatus.h"

@class WeiboStatus, WTCallback;

@interface WeiboComment : WeiboBaseStatus {
    WeiboStatus * replyToStatus;
    WeiboComment * replyToComment;
}

@property (readwrite,retain) WeiboStatus * replyToStatus;
@property (readwrite,retain) WeiboComment * replyToComment;

#pragma mark -
#pragma mark Parse Methods
+ (WeiboComment *)commentWithDictionary:(NSDictionary *)dic;
+ (WeiboComment *)commentWithJSON:(NSString *)json;
+ (NSArray *)commentsWithJSON:(NSString *)json;
+ (void)parseCommentsJSON:(NSString *)json callback:(WTCallback *)callback;
+ (void)parseCommentJSON:(NSString *)json callback:(WTCallback *)callback;

@end
