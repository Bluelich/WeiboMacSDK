//
//  NSObject+AssociatedObject.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-11.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociatedObject)

- (id)weibo_objectWithAssociatedKey:(NSString *)key;
- (void)weibo_setObject:(id)object forAssociatedKey:(NSString *)key retained:(BOOL)retain;

@end
