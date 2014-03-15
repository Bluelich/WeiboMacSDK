//
//  WeiboStatusAccountMentionFilter.h
//  Weibo
//
//  Created by Wutian on 13-8-20.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusFilter.h"

@class WeiboAccount;

@interface WeiboStatusAccountMentionFilter : WeiboStatusFilter

@property (nonatomic, weak) WeiboAccount * account;

@end
