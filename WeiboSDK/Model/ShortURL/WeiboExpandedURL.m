//
//  WeiboExpandedURL.m
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboExpandedURL.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboExpandedURL ()

@property (nonatomic, strong) NSString * shortURL;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, assign) WeiboExpandedURLType type;
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
        self.shortURL = [dict stringForKey:@"url_short" defaultValue:nil];
        self.originalURL = [dict stringForKey:@"url_long" defaultValue:nil];
        self.type = [dict intForKey:@"type" defaultValue:0];
        self.result = [dict boolForKey:@"result" defaultValue:YES];
        self.site = [self siteForURL:self.originalURL];
        
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
    
    NSInteger domainLength = domain.length;
    
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
    
#undef MAP
    
    return WeiboExpandedURLSiteUnknow;
}

@end
