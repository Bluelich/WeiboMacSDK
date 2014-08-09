//
//  WeiboConcreteStatusesStream.h
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStream.h"

extern NSString * const WeiboStatusStreamDidReceiveNewStatusesNotificationKey;
extern NSString * const WeiboStatusStreamDidReceiveRequestErrorNotificationKey;
extern NSString * const WeiboStatusStreamDidRemoveStatusNotificationKey;

extern NSString * const WeiboStatusStreamNotificationStatusesArrayKey;
extern NSString * const WeiboStatusStreamNotificationRequestErrorKey;
extern NSString * const WeiboStatusStreamNotificationBaseStatusKey;
extern NSString * const WeiboStatusStreamNotificationStatusIndexKey;
extern NSString * const WeiboStatusStreamNotificationAddingTypeKey;

@class WeiboBaseStatus, WeiboCallback;

@interface WeiboConcreteStatusesStream : WeiboStream

@property (nonatomic, strong) WeiboRequestError * loadNewerError;
@property (nonatomic, strong) WeiboRequestError * loadOlderError;

@property (nonatomic, assign, readonly) NSUInteger topStatusesCount;
@property (weak, nonatomic, readonly) WeiboBaseStatus * viewedMostRecentStatus;
@property (nonatomic, readonly) NSUInteger unreadCount;

@property (nonatomic, readonly) NSUInteger loadOlderSuccessTimes;

#pragma mark -
#pragma mark Accessors

- (NSMutableArray *)statuses;
- (void)setStatuses:(NSArray *)newStatuses;
- (void)addStatus:(WeiboBaseStatus *)newStatus;
- (void)addStatuses:(NSArray *)newStatuses;
- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type;
- (BOOL)appliesStatusFilter;
- (WeiboBaseStatus *)newestStatus;
- (WeiboBaseStatus *)oldestStatus;
- (WeiboStatusID)newestStatusID;
- (WeiboStatusID)oldestStatusID;
- (NSUInteger)maxCount;
- (NSUInteger)minStatusesToConsiderBeingGap;
- (BOOL)shouldIndexUsersInAutocomplete;
- (BOOL)isLoadingNewer;

- (WeiboBaseStatus *)statusWithID:(WeiboStatusID)sid;
- (void)markStatusWithIDAsRead:(WeiboStatusID)statusID;

#pragma mark -
#pragma mark Network Connecting
- (void)loadNewer;
- (void)loadOlder;
- (void)retryLoadOlder;
- (void)fillInGap:(NSString *)gap;
- (WeiboCallback *)loadNewerResponseCallback;
- (WeiboCallback *)loadOlderResponseCallback;
- (WeiboCallback *)fillInGapResponseCallback:(id)info;

#pragma mark -
#pragma mark On Disk Caching ( Not Implemented Yet )
- (NSString *)storedStreamPath;
- (void)saveStream;

#pragma mark -
#pragma mark Others
- (void)markAtEnd;
- (void)postStatusesChangedNotification;
- (void)deleteStatusNotification:(NSNotification *)notification;

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type;
- (void)noticeDidRemoveStatus:(WeiboBaseStatus *)status atIndex:(NSUInteger)index;

- (NSArray *)statusFilters;

@end
