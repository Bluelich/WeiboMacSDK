//
//  WeiboListStream.h
//  Weibo
//
//  Created by Wutian on 13-7-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAccountStream.h"

@class WeiboList;

@interface WeiboListStream : WeiboAccountStream

@property (nonatomic, weak) WeiboList * list;

@end
