//
//  WeiboUserList.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboRequestError.h"

@interface WeiboUserList : NSObject <NSCoding>

@property (weak, nonatomic, readonly) NSArray *users;
@property (nonatomic, strong) WeiboRequestError * loadNewerError;
@property (nonatomic, strong) WeiboRequestError * loadOlderError;

- (void)loadNewer;
- (void)loadOlder;
- (BOOL)isEnded;
- (void)retryLoadOlder;

@end
