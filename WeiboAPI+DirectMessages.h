//
//  WeiboAPI+DirectMessages.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (DirectMessages)

#pragma mark -
#pragma mark Direct Message
- (void)directMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;

@end
