//
//  WTCallback.h
//  Weibo
//
//  Created by Wu Tian on 12-2-9.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTCallback : NSObject {
    id target;
    SEL selector;
    id info;
}

WTCallback * WTCallbackMake(id aTarget,SEL aSelector,id aInfo);

+ (id)callbackWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo;
- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo;
- (void)invoke:(id)returnValue;
- (void)dissociateTarget;

@property(readonly, nonatomic) id info;
@property(readonly, nonatomic) SEL selector;
@property(readonly, nonatomic) id target;

@end
