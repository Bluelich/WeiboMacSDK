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

@protocol WeiboStreamDelegate;

@interface WeiboStream : NSObject {
    NSTimeInterval lastDismissTime;
    NSUInteger savedCellIndex;
    double savedRelativeOffset;
    id<WeiboStreamDelegate> _delegate;
}

@property (nonatomic) NSTimeInterval lastDismissTime;
@property (retain, nonatomic) NSMutableArray * statuses;
@property (assign) NSUInteger savedCellIndex;
@property (assign) double savedRelativeOffset;
@property (assign, nonatomic) id<WeiboStreamDelegate> delegate;

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

@protocol WeiboStreamDelegate <NSObject>
- (void)statusesStream:(WeiboStream *)stream didReciveNewStatuses:(NSArray *)status withAddingType:(WeiboStatusesAddingType)type;
- (void)statusesStream:(WeiboStream *)stream didReciveRequestError:(WeiboRequestError *)error;
- (void)statusesStream:(WeiboStream *)stream didRemoveStatus:(WeiboBaseStatus *)status atIndex:(NSInteger)index;
@end
