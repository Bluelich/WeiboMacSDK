//
//  WeiboShortURL.m
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboShortURL.h"
#import "NSDictionary+WeiboAdditions.h"

@interface WeiboShortURL ()

@property (nonatomic, strong) NSString * shortURL;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, assign) WeiboShortURLType type;
@property (nonatomic, assign) WeiboShortURLSite site;
@property (nonatomic, assign) BOOL result;

@end

@implementation WeiboShortURL

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

- (WeiboShortURLSite)siteForURL:(NSString *)urlString
{
    if (!urlString.length) return WeiboShortURLSiteUnknow;
    NSURL * URL = [NSURL URLWithString:urlString];
    if (!URL) return WeiboShortURLSiteUnknow;
    NSString * domain = URL.host;
    if (!domain.length) return WeiboShortURLSiteUnknow;
    domain = [domain lowercaseString];
    
    NSInteger domainLength = domain.length;
    
#define MAP(_suffix_, _result_) \
    if ([domain hasSuffix:_suffix_]) { \
        if (domainLength > _suffix_.length) { \
            unichar dot = [domain characterAtIndex:(domainLength - _suffix_.length - 1)]; \
            if (dot != '.') return WeiboShortURLSiteUnknow; \
        } \
        return _result_; \
    }

    MAP(@"youku.com", WeiboShortURLSiteYouku);
    MAP(@"56.com", WeiboShortURLSite56);
    MAP(@"tudou.com", WeiboShortURLSiteTudou);
    MAP(@"iqiyi.com", WeiboShortURLSiteQiyi);
    MAP(@"letv.com", WeiboShortURLSiteLeTV);
    MAP(@"ku6.com", WeiboShortURLSiteKu6);
    MAP(@"ifeng.com", WeiboShortURLTypeIFeng);
    MAP(@"sina.com", WeiboShortURLSiteSina);
    MAP(@"sina.com.cn", WeiboShortURLSiteSina);
    MAP(@"weibo.com", WeiboShortURLSiteWeibo);
    MAP(@"weibo.cn", WeiboShortURLSiteWeibo);
    MAP(@"weiboformac.sinaapp.com", WeiboShortURLSiteWeiboX);
    MAP(@"douban.com", WeiboShortURLSiteDouban);
    MAP(@"zhihu.com", WeiboShortURLSiteZhihu);
    MAP(@"xunlei.com", WeiboShortURLSiteXunlei);
    MAP(@"qq.com", WeiboShortURLSiteTencent);
    MAP(@"163.com", WeiboShortURLSiteNetease);
    MAP(@"sohu.com", WeiboShortURLSiteSohu);
    MAP(@"xiami.com", WeiboShortURLSiteXiami);
    MAP(@"github.com", WeiboShortURLSiteGithub);
    MAP(@"digtle.com", WeiboShortURLSiteDigtle);
    MAP(@"apple.com", WeiboShortURLSiteApple);
    MAP(@"google.com", WeiboShortURLSiteGoogle);
    
#undef MAP
    
    return WeiboShortURLSiteUnknow;
}

@end
