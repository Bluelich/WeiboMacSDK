//
//  WeiboRepliesStream.h
//  Weibo
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@class WeiboStatus;

@interface WeiboRepliesStream : WeiboAccountStream {
    WeiboStatus * baseStatus;
    NSUInteger loadedPage;
}

@property (retain, nonatomic) WeiboStatus * baseStatus;

@end
