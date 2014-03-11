//
//  WeiboAccountStream.h
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboConcreteStatusesStream.h"

@class WeiboAccount, WeiboBaseStatus;

@interface WeiboAccountStream : WeiboConcreteStatusesStream <WeiboModelPersistence>
{
    WeiboAccount * account;
}

@property (retain, nonatomic) WeiboAccount * account;

- (WeiboBaseStatus *)newestStatusThatIsNotMine;

@end
