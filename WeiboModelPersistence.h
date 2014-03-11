//
//  WeiboModelPersistence.h
//  Weibo
//
//  Created by Wutian on 14-3-11.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WeiboAccount;

@protocol WeiboModelPersistence <NSObject>

@required
+ (instancetype)objectWithPersistenceInfo:(id)info forAccount:(WeiboAccount *)account;
- (id)persistenceInfo;
- (WeiboUserID)persistenceAccountID;

@end
