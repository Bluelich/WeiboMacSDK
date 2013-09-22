//
//  WeiboStatusAdvertisementFilter.m
//  Weibo
//
//  Created by Wutian on 13-9-22.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusAdvertisementFilter.h"
#import "WeiboBaseStatus.h"

@implementation WeiboStatusAdvertisementFilter

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    return status.isAdvertisement;
}

@end
