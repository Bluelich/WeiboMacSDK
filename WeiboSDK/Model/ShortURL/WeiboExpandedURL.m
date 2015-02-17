//
//  WeiboExpandedURL.m
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboExpandedURL.h"

@interface WeiboExpandedURL ()

@property (nonatomic, strong) NSString * shortURL;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, assign) WeiboExpandedURLType type;
@property (nonatomic, assign) WeiboExpandedURLType derivedType;
@property (nonatomic, assign) WeiboExpandedURLSite site;
@property (nonatomic, assign) BOOL result;

@end

@implementation WeiboExpandedURL

+ (NSString *)defaultJSONArrayRootKey
{
    return @"urls";
}

+ (NSString *)defaultJSONObjectRootKey
{
    return @"url";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.shortURL = [dict stringForKey:@"url_short"];
        self.originalURL = [dict stringForKey:@"url_long"];
        self.type = [dict intForKey:@"type"];
        self.result = [dict boolForKey:@"result"];
        self.site = [self siteForURL:self.originalURL];
        self.derivedType = [self _derivedType];
        
        return YES;
    }
    return NO;
}

- (WeiboExpandedURLSite)siteForURL:(NSString *)urlString
{
    if (!urlString.length) return WeiboExpandedURLSiteUnknow;
    NSURL * URL = [NSURL URLWithString:urlString];
    if (!URL) return WeiboExpandedURLSiteUnknow;
    NSString * domain = URL.host;
    if (!domain.length) return WeiboExpandedURLSiteUnknow;
    domain = [domain lowercaseString];
    
    NSUInteger domainLength = domain.length;
    
#define MAP(_suffix_, _result_) \
    if ([domain hasSuffix:_suffix_]) { \
        if (domainLength > _suffix_.length) { \
            unichar dot = [domain characterAtIndex:(domainLength - _suffix_.length - 1)]; \
            if (dot != '.') return WeiboExpandedURLSiteUnknow; \
        } \
        return _result_; \
    }

    MAP(@"youku.com", WeiboExpandedURLSiteYouku);
    MAP(@"56.com", WeiboExpandedURLSite56);
    MAP(@"tudou.com", WeiboExpandedURLSiteTudou);
    MAP(@"iqiyi.com", WeiboExpandedURLSiteQiyi);
    MAP(@"letv.com", WeiboExpandedURLSiteLeTV);
    MAP(@"ku6.com", WeiboExpandedURLSiteKu6);
    MAP(@"ifeng.com", WeiboExpandedURLSiteIFeng);
    MAP(@"sina.com", WeiboExpandedURLSiteSina);
    MAP(@"sina.com.cn", WeiboExpandedURLSiteSina);
    MAP(@"weibo.com", WeiboExpandedURLSiteWeibo);
    MAP(@"weibo.cn", WeiboExpandedURLSiteWeibo);
    MAP(@"weiboformac.sinaapp.com", WeiboExpandedURLSiteWeiboX);
    MAP(@"douban.com", WeiboExpandedURLSiteDouban);
    MAP(@"zhihu.com", WeiboExpandedURLSiteZhihu);
    MAP(@"xunlei.com", WeiboExpandedURLSiteXunlei);
    MAP(@"qq.com", WeiboExpandedURLSiteTencent);
    MAP(@"163.com", WeiboExpandedURLSiteNetease);
    MAP(@"sohu.com", WeiboExpandedURLSiteSohu);
    MAP(@"xiami.com", WeiboExpandedURLSiteXiami);
    MAP(@"github.com", WeiboExpandedURLSiteGithub);
    MAP(@"digtle.com", WeiboExpandedURLSiteDigtle);
    MAP(@"apple.com", WeiboExpandedURLSiteApple);
    MAP(@"google.com", WeiboExpandedURLSiteGoogle);
    MAP(@"youtube.com", WeiboExpandedURLSiteYoutube);
    MAP(@"techweb.com.cn", WeiboExpandedURLSiteTechWeb);
    MAP(@"baidu.com", WeiboExpandedURLSiteBaidu);
    MAP(@"xiaomi.com", WeiboExpandedURLSiteXiaomi);
    MAP(@"yixia.com", WeiboExpandedURLSiteYixia);
    MAP(@"yinyuetai.com", WeiboExpandedURLSiteYinyuetai);
    
#undef MAP
    
    return WeiboExpandedURLSiteUnknow;
}

- (WeiboExpandedURLType)_derivedType
{
    WeiboExpandedURLType type = _type;
    
    switch (_site)
    {
        case WeiboExpandedURLSiteYouku:
        {
            if ([_originalURL rangeOfString:@"youku.com/v_show/id_"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        case WeiboExpandedURLSite56:
        {
            if ([_originalURL rangeOfString:@"/v_"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        case WeiboExpandedURLSiteLeTV:
        {
            if ([_originalURL rangeOfString:@"letv.com/ptv/vplay"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        case WeiboExpandedURLSiteYixia:
        {
            if ([_originalURL rangeOfString:@"yixia.com/show/"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        case WeiboExpandedURLSiteYinyuetai:
        {
            if ([_originalURL rangeOfString:@"v.yinyuetai.com/"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        case WeiboExpandedURLSiteWeibo:
        {
            if ([_originalURL rangeOfString:@"video.weibo.com/show"].location != NSNotFound)
            {
                type = WeiboExpandedURLTypeVideo;
            }
            break;
        }
        default:
            break;
    }
    
    return type;
}

@end
