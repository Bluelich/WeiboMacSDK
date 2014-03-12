//
//  WeiboLikesStream.h
//  Weibo
//
//  Created by Wutian on 14-3-10.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@class WeiboStatus;

@interface WeiboLikesStream : WeiboAccountStream

@property (nonatomic, strong) WeiboStatus * baseStatus;

@end
