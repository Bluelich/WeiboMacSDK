//
//  WeiboUserList.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboRequestError.h"

@interface WeiboUserList : NSObject

@property (nonatomic, readonly) NSArray *users;
@property (nonatomic, retain) WeiboRequestError * loadNewerError;
@property (nonatomic, retain) WeiboRequestError * loadOlderError;

- (void)loadNewer;
- (void)loadOlder;
- (BOOL)isEnded;
- (void)retryLoadOlder;

@end
