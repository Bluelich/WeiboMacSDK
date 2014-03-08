//
//  WeiboShortURLManager.h
//  Weibo
//
//  Created by Wutian on 14-2-15.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WeiboShortURLType)
{
    WeiboShortURLTypeWebpage = 0,
    WeiboShortURLTypeLocation,
    WeiboShortURLTypeYouku,
    WeiboShortURLType56,
    WeiboShortURLTypeTudou,
    WeiboShortURLTypeDouban,
    WeiboShortURLTypeZhihu,
    WeiboShortURLTypeXunlei,
    WeiboShortURLTypeNetease,
    WeiboShortURLTypeSohu,
    WeiboShortURLTypeXiami,
    WeiboShortURLTypeGithub,
    WeiboShortURLTypeDigtle,
    WeiboShortURLTypeApple,
    WeiboShortURLTypeGoogle,
};

@interface WeiboShortURLManager : NSObject

@end
