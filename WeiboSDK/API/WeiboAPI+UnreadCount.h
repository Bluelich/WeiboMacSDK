//
//  WeiboAPI+UnreadCount.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (UnreadCount)

- (void)unreadCountSinceID:(WeiboStatusID)since;
- (void)unreadCount;
- (void)resetUnreadWithType:(WeiboUnreadCountType)type;

@end
