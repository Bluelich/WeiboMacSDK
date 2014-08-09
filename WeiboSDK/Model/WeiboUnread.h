//
//  WeiboUnread.h
//  Weibo
//
//  Created by Wu Tian on 12-2-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"

@class WeiboCallback;

@interface WeiboUnread : WeiboModel {
    NSUInteger newStatus;
    NSUInteger newFollowers;
    NSUInteger newDirectMessages;
    NSUInteger newStatusMentions;
    NSUInteger newCommentMentions;
    NSUInteger newComments;
}

@property (assign, nonatomic) NSUInteger newStatus;
@property (assign, nonatomic) NSUInteger newFollowers;
@property (assign, nonatomic) NSUInteger newDirectMessages;
@property (assign, nonatomic) NSUInteger newStatusMentions;
@property (assign, nonatomic) NSUInteger newCommentMentions;
@property (assign, nonatomic) NSUInteger newComments;

@end
