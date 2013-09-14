//
//  NSArray+WeiboAdditions.h
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (WeiboAdditions)

@property (nonatomic, retain, readonly) id firstObject;

typedef NSComparisonResult (^CompareObjects) (id, id);
- (NSInteger)binarySearch:(id)key usingBlock:(CompareObjects)comparator;

@end
