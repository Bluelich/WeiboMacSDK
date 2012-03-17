//
//  WeiboAppDelegate.h
//  Weibo
//
//  Created by Wu Tian on 12-2-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboAPI.h"
#import "WTCallback.h"

@interface WeiboAppDelegate : NSObject <NSApplicationDelegate> {
    WeiboAPI * api;
    NSUInteger count;
}

@end
