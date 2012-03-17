//
//  WTFoundationUtilities.h
//  Weibo
//
//  Created by Wu Tian on 12-2-13.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

static void QuietLog (NSString *format, ...) {
    va_list argList;
    va_start (argList, format);
    NSString *message = [[[NSString alloc] initWithFormat: format
                                                arguments: argList] autorelease];
    fprintf (stderr, "%s\n", [message UTF8String]);
    va_end  (argList);
}

static void LogIt (id format, ...) {
    va_list args;
    va_start (args, format);
    NSString *string;
    string = [[NSString alloc] initWithFormat: format  arguments: args];
    va_end (args);
    fprintf (stderr, "%s\n", [string UTF8String]);
    [string release];
}

#define WeiboUnimplementedMethod NSLog(@"[Warning - Weibo SDK] A Unimplemented Method Has Been Called. In File:%s , Line:%d.", __FILE__, __LINE__);