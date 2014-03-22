//
//  WTFoundationUtilities.h
//  Weibo
//
//  Created by Wu Tian on 12-2-13.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE void QuietLog (NSString *format, ...) {
    va_list argList;
    va_start (argList, format);
    NSString *message = [[NSString alloc] initWithFormat: format
                                                arguments: argList];
    fprintf (stderr, "%s\n", [message UTF8String]);
    va_end  (argList);
}

NS_INLINE void LogIt (id format, ...) {
    va_list args;
    va_start (args, format);
    NSString *string;
    string = [[NSString alloc] initWithFormat: format  arguments: args];
    va_end (args);
    fprintf (stderr, "%s\n", [string UTF8String]);
}

NS_INLINE void LogBinary (NSUInteger theNumber,NSInteger bits) {
    NSMutableString *str = [NSMutableString string];
    NSUInteger numberCopy = theNumber; // so you won't change your original value
    for(NSInteger i = 0; i < bits ; i++) {
        // Prepend "0" or "1", depending on the bit
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
        numberCopy >>= 1;
    }
    NSLog(@"Binary version: %@", str);
}

#if !__has_feature(objc_arc)
#define SetRetainedIvar(ivar, newVar) [newVar retain];\
[ivar release];\
ivar = newVar;

#define SetAtomicRetainedIvar(ivar, newVar) @synchronized(self) {[newVar retain];\
[ivar release];\
ivar = newVar;}

#define SetCopiedIvar(ivar, newVar) [newVar copy];\
[ivar release];\
ivar = newVar;
#else
#define SetRetainedIvar(ivar, newVar) ivar = newVar;
#define SetAtomicRetainedIvar(ivar, newVar) ivar = newVar;
#define SetCopiedIvar(ivar, newVar) ivar = newVar;
#endif

#define BETWEEN(min, x, max) MIN(MAX(min, x), max)

NS_INLINE void dispatch_next(dispatch_block_t block)
{
    dispatch_async(dispatch_get_current_queue(), block);
}
NS_INLINE void dispatch_async_priority(NSInteger priority, dispatch_block_t work)
{
    dispatch_async(dispatch_get_global_queue(priority, 0), ^{
        work();
    });
}
NS_INLINE void dispatch_async_default(dispatch_block_t work)
{
    dispatch_async_priority(DISPATCH_QUEUE_PRIORITY_DEFAULT, work);
}
NS_INLINE void dispatch_async_low(dispatch_block_t work)
{
    dispatch_async_priority(DISPATCH_QUEUE_PRIORITY_LOW, work);
}
NS_INLINE void dispatch_async_high(dispatch_block_t work)
{
    dispatch_async_priority(DISPATCH_QUEUE_PRIORITY_HIGH, work);
}
NS_INLINE void dispatch_async_background(dispatch_block_t work)
{
    dispatch_async_priority(DISPATCH_QUEUE_PRIORITY_BACKGROUND, work);
}
NS_INLINE void dispatch_async_main(dispatch_block_t work)
{
    dispatch_async(dispatch_get_main_queue(), work);
}