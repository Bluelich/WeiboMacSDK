//
//  WeiboSearchUserList.h
//  Weibo
//
//  Created by Wutian on 13-10-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserUserList.h"

@interface WeiboSearchUserList : WeiboUserUserList <WeiboModelPersistence>

@property (nonatomic, strong) NSString * keyword;

@end
