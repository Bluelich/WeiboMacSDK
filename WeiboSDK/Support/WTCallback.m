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

+ (WTCallback *)callbackWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo{
    return [[WTCallback alloc] initWithTarget:aTarget selector:aSelector info:aInfo];
}
WTCallback * WTCallbackMake(id aTarget,SEL aSelector,id aInfo){
    return [WTCallback callbackWithTarget:aTarget selector:aSelector info:aInfo];
}
WTCallback * WTBlockCallback(WTCallbackBlock block, id aInfo)
{
    return [[WTCallback alloc] initWithBlock:block info:aInfo];
}
- (WTCallback *)initWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo{
    if ((self = [super init])) {
        _target = aTarget;
        _selector = aSelector;
        _info = aInfo;
    }
    return self;
}
- (id)initWithBlock:(WTCallbackBlock)block info:(id)aInfo
{
    if (self = [super init])
    {
        self.block = block;
        _info = aInfo;
    }
    return self;
}
- (void)dealloc{
    _block = nil;
}
- (void)invoke:(id)returnValue{
    if (self.block)
    {
        self.block(returnValue, _info);
    }
    
    if (self.target && _selector)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_selector withObject:returnValue withObject:_info];
#pragma clang diagnostic pop
    }
    [self dissociateTarget];
}
- (void)dissociateTarget{
    _block = nil;
    _target = nil;
}
- (NSString *)description{
    return [NSString stringWithFormat:
            @"Callback to %@'s %@ method, with info:%@",_target,NSStringFromSelector(_selector),_info];
}

@end
