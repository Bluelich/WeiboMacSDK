//
//  WeiboRepostsStream.h
//  Weibo
//
//  Created by Wutian on 13-12-19.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@class WeiboStatus;

@interface WeiboRepostsStream : WeiboAccountStream

@property (nonatomic, retain) WeiboStatus * baseStatus;

@end
