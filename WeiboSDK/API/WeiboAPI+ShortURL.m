//
//  WeiboAPI+ShortURL.m
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboAPI+ShortURL.h"
#import "WeiboAPI+Private.h"
#import "WeiboExpandedURL.h"

@implementation WeiboAPI (ShortURL)

- (void)expandShortURLs:(NSSet *)urls
{
    if (!urls.count) return;
    
    [self GET:@"short_url/expand.json" parameters:@{@"url_short": urls} callback:WeiboBlockCallback(^(id responseObject, id info __attribute__((unused))) {
        [WeiboExpandedURL parseObjectsWithJSONObject:responseObject account:self->authenticateWithAccount callback:self->responseCallback];
    }, nil)];
}

@end
