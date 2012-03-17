//
//  WeiboConcreteStatusesStream.h
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStream.h"
#import "WeiboConstants.h"

@class WeiboBaseStatus, WTCallback;

@interface WeiboConcreteStatusesStream : WeiboStream {
    NSString * guid;
    NSMutableArray * statuses;
    NSDate * lastUpdated;
    struct {
		unsigned int isLoadingNewer:1;
		unsigned int isLoadingOlder:1;
        unsigned int isAtEnd:1;
        unsigned int shouldAutoClearUp:1;
        unsigned int isKeyStream:1;
	} _flags;
    
    
}

#pragma mark -
#pragma mark Accessors
- (NSString *)guid;
- (NSMutableArray *)statuses;
- (void)setStatuses:(NSArray *)newStatuses;
- (void)addStatus:(WeiboBaseStatus *)newStatus;
- (void)addStatuses:(NSArray *)newStatuses;
- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type;
- (WeiboBaseStatus *)newestStatus;
- (WeiboBaseStatus *)oldestStatus;
- (WeiboStatusID)newestStatusID;
- (WeiboStatusID)oldestStatusID;
- (NSDate *)lastUpdated;
- (NSUInteger)maxCount;
- (NSUInteger)minStatusesToConsiderBeingGap;
- (BOOL)shouldIndexUsersInAutocomplete;
- (BOOL)isLoadingNewer;

#pragma mark -
#pragma mark Network Connecting
- (void)loadNewer;
- (void)loadOlder;
- (void)retryLoadOlder;
- (void)fillInGap:(NSString *)gap;
- (WTCallback *)loadNewerResponseCallback;
- (WTCallback *)loadOlderResponseCallback;
- (WTCallback *)fillInGapResponseCallback:(id)info;

#pragma mark -
#pragma mark On Disk Caching ( Not Implemented Yet )
- (NSString *)storedStreamPath;
- (void)saveStream;


#pragma mark -
#pragma mark Others
- (void)markAtEnd;
- (void)postStatusesChangedNotification;
- (void)deleteStatusNotification:(NSNotification *)notification;


@end
