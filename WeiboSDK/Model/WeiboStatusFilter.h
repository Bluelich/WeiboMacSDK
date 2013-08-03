//
//  WeiboStatusFilter.h
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboBaseStatus;

@interface WeiboStatusFilter : NSObject

- (BOOL)validateStatus:(WeiboBaseStatus *)status;

@end
