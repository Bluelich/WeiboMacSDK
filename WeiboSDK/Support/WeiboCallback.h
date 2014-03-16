//
//  WeiboCallback.h
//  Weibo
//
//  Created by Wu Tian on 12-2-9.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WeiboCallbackBlock)(id responseObject, id info);

@interface WeiboCallback : NSObject

WeiboCallback * WeiboCallbackMake(id aTarget,SEL aSelector,id aInfo);
WeiboCallback * WeiboBlockCallback(WeiboCallbackBlock block, id aInfo);

+ (id)callbackWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo;
- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector info:(id)aInfo;
- (id)initWithBlock:(WeiboCallbackBlock)block info:(id)info;
- (void)invoke:(id)returnValue;
- (void)dissociateTarget;

@property(readonly, nonatomic, strong) id info;
@property(readonly, nonatomic, assign) SEL selector;
@property(readonly, nonatomic, strong) id target;
@property(readonly, nonatomic, copy) WeiboCallbackBlock block;

@end
