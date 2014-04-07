//
//  WeiboExpandedURL.h
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboModel.h"

typedef NS_ENUM(NSInteger, WeiboExpandedURLType)
{
    WeiboExpandedURLTypeWebpage    = 0,
    WeiboExpandedURLTypeVideo      = 1,
    WeiboExpandedURLTypeMusic      = 2,
    WeiboExpandedURLTypeEvent      = 3,
    WeiboExpandedURLTypeVotes      = 5,
    
    WeiboExpandedURLTypeLocation   = 36,
    WeiboExpandedURLTypeMiaoPai    = 39,
};

typedef NS_ENUM(NSInteger, WeiboExpandedURLSite)
{
    WeiboExpandedURLSiteUnknow = 0,
    WeiboExpandedURLSiteYouku,
    WeiboExpandedURLSite56,
    WeiboExpandedURLSiteTudou,
    WeiboExpandedURLSiteQiyi,
    WeiboExpandedURLSiteLeTV,
    WeiboExpandedURLSiteKu6,
    WeiboExpandedURLSiteIFeng,
    WeiboExpandedURLSiteSina,
    WeiboExpandedURLSiteWeibo,
    WeiboExpandedURLSiteWeiboX,
    WeiboExpandedURLSiteDouban,
    WeiboExpandedURLSiteZhihu,
    WeiboExpandedURLSiteXunlei,
    WeiboExpandedURLSiteTencent,
    WeiboExpandedURLSiteNetease,
    WeiboExpandedURLSiteSohu,
    WeiboExpandedURLSiteXiami,
    WeiboExpandedURLSiteGithub,
    WeiboExpandedURLSiteDigtle,
    WeiboExpandedURLSiteApple,
    WeiboExpandedURLSiteGoogle,
    WeiboExpandedURLSiteYoutube,
};

@interface WeiboExpandedURL : WeiboModel

@property (nonatomic, strong, readonly) NSString * shortURL;
@property (nonatomic, strong, readonly) NSString * originalURL;
@property (nonatomic, assign, readonly) WeiboExpandedURLType type;
@property (nonatomic, assign, readonly) WeiboExpandedURLSite site;
@property (nonatomic, assign, readonly) BOOL result;

@end
