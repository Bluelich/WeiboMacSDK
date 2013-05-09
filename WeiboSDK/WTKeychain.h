//
//  WTKeychain.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTKeychain : NSObject

+ (id)setPassword:(id)arg1 forUsername:(id)arg2 serviceName:(id)arg3;
+ (id)passwordForUsername:(id)arg1 serviceName:(id)arg2 error:(id *)arg3;

@end
