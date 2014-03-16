//
//  WeiboComment.h
//  Weibo
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboBaseStatus.h"

@class WeiboStatus, WeiboCallback;

@interface WeiboComment : WeiboBaseStatus {
    WeiboStatus * replyToStatus;
    WeiboComment * replyToComment;
}

@property (readwrite,strong) WeiboStatus * replyToStatus;
@property (readwrite,strong) WeiboComment * replyToComment;

@property (nonatomic, assign) BOOL treatReplyingStatusAsQuoted;
@property (nonatomic, assign) BOOL treatReplyingCommentAsQuoted;

@end
