//
//  WeiboStatusFilter.h
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboBaseStatus;

@interface WeiboStatusFilter : NSObject <NSCoding>

@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSTimeInterval expireTime;

@property (nonatomic, assign, readonly) NSTimeInterval duration;

@property (nonatomic, assign) BOOL filterQuotedStatus;

- (BOOL)validateStatus:(WeiboBaseStatus *)status;

@end
