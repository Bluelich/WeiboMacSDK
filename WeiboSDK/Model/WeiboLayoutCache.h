//
//  WeiboLayoutCache.h
//  Weibo
//
//  Created by 吴 天 on 12-11-25.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboLayoutCache : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) BOOL fontSize;
@property (nonatomic, assign) BOOL showThumb;
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CGFloat textHeightOfQuotedStatus;
@property (nonatomic, assign) CGFloat height;

@end
