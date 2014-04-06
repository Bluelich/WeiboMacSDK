//
//  WeiboShortURL.h
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboModel.h"

typedef NS_ENUM(NSInteger, WeiboShortURLType)
{
    WeiboShortURLTypeWebpage    = 0,
    WeiboShortURLTypeVideo      = 1,
    WeiboShortURLTypeMusic      = 2,
    WeiboShortURLTypeEvent      = 3,
    WeiboShortURLTypeVotes      = 5,
};

typedef NS_ENUM(NSInteger, WeiboShortURLSite)
{
    WeiboShortURLSiteUnknow = 0,
    WeiboShortURLSiteYouku,
    WeiboShortURLSite56,
    WeiboShortURLSiteTudou,
    WeiboShortURLSiteQiyi,
    WeiboShortURLSiteLeTV,
    WeiboShortURLSiteKu6,
    WeiboShortURLTypeIFeng,
    WeiboShortURLSiteSina,
    WeiboShortURLSiteWeibo,
    WeiboShortURLSiteWeiboX,
    WeiboShortURLSiteDouban,
    WeiboShortURLSiteZhihu,
    WeiboShortURLSiteXunlei,
    WeiboShortURLSiteTencent,
    WeiboShortURLSiteNetease,
    WeiboShortURLSiteSohu,
    WeiboShortURLSiteXiami,
    WeiboShortURLSiteGithub,
    WeiboShortURLSiteDigtle,
    WeiboShortURLSiteApple,
    WeiboShortURLSiteGoogle,
};

@interface WeiboShortURL : WeiboModel

@property (nonatomic, strong, readonly) NSString * shortURL;
@property (nonatomic, strong, readonly) NSString * originalURL;
@property (nonatomic, assign, readonly) WeiboShortURLType type;
@property (nonatomic, assign, readonly) WeiboShortURLSite site;
@property (nonatomic, assign, readonly) BOOL result;

@end
