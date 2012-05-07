//
//  WeiboStatusStreamFilter.h
//  Weibo
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboBaseStatus;

@interface WeiboStatusStreamFilter : NSObject

+ (id)defaultStatusStreamFilter;
- (BOOL)validStatus:(WeiboBaseStatus *)status;

@end
