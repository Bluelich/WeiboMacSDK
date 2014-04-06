//
//  WeiboAPI+ShortURL.h
//  Weibo
//
//  Created by Wutian on 14-4-6.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (ShortURL)

- (void)expandShortURLs:(NSSet *)urls;

@end
