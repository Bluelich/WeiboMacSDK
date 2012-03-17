//
//  WeiboAppDelegate.m
//  Weibo
//
//  Created by Wu Tian on 12-2-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WeiboAppDelegate.h"
#import "WeiboAccount.h"
#import "Weibo.h"
#import "WeiboComposition.h"
#import "WTHTTPRequest.h"

#import "RegexKitLite.h"

@implementation WeiboAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)callbackWithObject:(id)object info:(id)info{
    if ([object isKindOfClass:[NSError class]]) {
        NSLog(@"error:%ld",[(NSError *)object code]);
    }
    else{
        NSLog(@"%@",object);
    }
}

- (void)checkCount{
}

- (void)networkStressTest{
    for (int i = 0; i < 1; i++) {
        WTCallback * resCallback = [WTCallback callbackWithTarget:self selector:@selector(callbackWithObject:info:) info:@"haha"];
        WTHTTPRequest * request = [WTHTTPRequest requestWithURL:[NSURL URLWithString:@"http://apple.com"]];
        [request setResponseCallback:resCallback];
        [request start];
    }
}

- (void)getStatuses{
    [[[Weibo sharedWeibo] defaultAccount] refreshTimelines];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    for (int i = 0; i < 1; i++) {
        Weibo * engine = [Weibo sharedWeibo];
        WTCallback * callback = WTCallbackMake(self, @selector(getStatuses), nil);
        [engine signInWithUsername:@"naituw@gmail.com" 
                                              password:@"DAOhaoSHIzhu5586" 
                                              callback:callback];
    }
    
    for (int i = 0; i < 0; i++) {
        WeiboComposition * com = [[WeiboComposition alloc] init];
        [com refreshLocation];
    }
    
    for (int i = 0; i < 0; i++) {
        /*
        NSString * shortedLinkRegex = @"(http://t.cn/)([a-zA-Z0-9]+)";
        NSString * linkRegex = @"(?i)https?://[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*";
        NSString * atRegex = @"@([\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]+)";
        NSString * hashtagRegex = @"#(.+?)#";
        
        NSString * string = @"adfk;哈哈http://t.cn 你好@你好#你好#\n\nhttp://t.cn/asdffasdf";
        NSLog(@"%@",[[[string arrayOfCaptureComponentsMatchedByRegex:hashtagRegex] objectAtIndex:0] objectAtIndex:0]);
         */
    }
    
    
}

@end
