//
//  WeiboStream.h
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WeiboRequestError, WeiboBaseStatus;

@interface WeiboStream : NSObject {
    NSTimeInterval cacheTime;
    NSUInteger savedCellIndex;
    double savedRelativeOffset;
}

@property (assign, nonatomic) NSTimeInterval cacheTime;
@property (retain, nonatomic) NSMutableArray * statuses;
@property (assign) NSUInteger savedCellIndex;
@property (assign) double savedRelativeOffset;
@property (assign) WeiboStatusID viewedMostRecentID;

- (BOOL)canLoadNewer;
- (void)loadNewer;
- (void)loadOlder;
- (void)retryLoadOlder;
- (void)fillInGap:(NSString *)before;
- (BOOL)supportsFillingInGaps;
- (BOOL)hasData;
- (void)didLoadOlder;
- (NSString *)autosaveName;
- (NSUInteger)statuseIndexByID:(WeiboStatusID)theID;
- (BOOL)isStreamEnded;

@end