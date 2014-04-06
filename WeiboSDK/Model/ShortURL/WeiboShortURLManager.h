//
//  WeiboShortURLManager.h
//  Weibo
//
//  Created by Wutian on 14-2-15.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboShortURLManager : NSObject

+ (instancetype)defaultManager;

- (void)enqueueShortURL:(NSString *)shortURL;

@end
