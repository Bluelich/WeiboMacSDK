//
//  WeiboCommentConversationStream.h
//  Weibo
//
//  Created by Wutian on 13-10-13.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@class WeiboComment;

@interface WeiboCommentConversationStream : WeiboAccountStream

@property (nonatomic, strong) WeiboComment * sourceComment;

@end
