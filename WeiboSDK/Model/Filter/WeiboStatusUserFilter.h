//
//  WeiboStatusUserFilter.h
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusFilter.h"

@interface WeiboStatusUserFilter : WeiboStatusFilter

@property (nonatomic, copy) NSString * screenname;
@property (nonatomic, assign) WeiboUserID userID;

@end
