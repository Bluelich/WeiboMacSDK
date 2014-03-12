//
//  WeiboSearchStatusesStream.h
//  Weibo
//
//  Created by Wutian on 13-10-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@interface WeiboSearchStatusesStream : WeiboAccountStream

@property (nonatomic, strong) NSString * keyword;

@end
