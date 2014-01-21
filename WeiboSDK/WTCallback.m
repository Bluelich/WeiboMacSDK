//
//  WTCallback.m
//  Weibo
//
//  Created by Wu Tian on 12-2-9.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTCallback.h"

@interface WTCallback ()

@property (nonatomic, copy) WTCallbackBlock block;

@end

@implementation WTCallback
@synthesize target, selector, info;

+ (WTCallback *)callbackWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo{
    return [[[WTCallback alloc] initWithTarget:aTarget selector:aSelector info:aInfo] autorelease];
}
WTCallback * WTCallbackMake(id aTarget,SEL aSelector,id aInfo){
    return [WTCallback callbackWithTarget:aTarget selector:aSelector info:aInfo];
}
WTCallback * WTBlockCallback(WTCallbackBlock block, id aInfo)
{
    return [[[WTCallback alloc] initWithBlock:block info:aInfo] autorelease];
}
- (WTCallback *)initWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo{
    if ((self = [super init])) {
        target = [aTarget retain];
        selector = aSelector;
        info = [aInfo retain];
    }
    return self;
}
- (id)initWithBlock:(WTCallbackBlock)block info:(id)aInfo
{
    if (self = [super init])
    {
        self.block = block;
        info = [aInfo retain];
    }
    return self;
}
- (void)dealloc{
    [info release]; info = nil;
    [_block release], _block = nil;
    [super dealloc];
}
- (void)invoke:(id)returnValue{
    if (self.block)
    {
        self.block(returnValue, info);
    }
    
    if (self.target && selector)
    {
        [target performSelector:selector withObject:returnValue withObject:info];
    }
    [self dissociateTarget];
}
- (void)dissociateTarget{
    [_block release], _block = nil;
    [target release];
    target = nil;
}
- (NSString *)description{
    return [NSString stringWithFormat:
            @"Callback to %@'s %@ method, with info:%@",target,NSStringFromSelector(selector),info];
}

@end
