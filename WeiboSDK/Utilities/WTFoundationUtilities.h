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

static void LogBinary (NSUInteger theNumber,NSInteger bits) {
    NSMutableString *str = [NSMutableString string];
    NSUInteger numberCopy = theNumber; // so you won't change your original value
    for(NSInteger i = 0; i < bits ; i++) {
        // Prepend "0" or "1", depending on the bit
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
        numberCopy >>= 1;
    }
    NSLog(@"Binary version: %@", str);
}

#define SetRetainedIvar(ivar, newVar) [newVar retain];\
[ivar release];\
ivar = newVar;

#define SetAtomicRetainedIvar(ivar, newVar) @synchronized(self) {[newVar retain];\
[ivar release];\
ivar = newVar;}

#define SetCopiedIvar(ivar, newVar) [newVar copy];\
[ivar release];\
ivar = newVar;

static void dispatch_next(dispatch_block_t block)
{
    dispatch_async(dispatch_get_current_queue(), block);
}