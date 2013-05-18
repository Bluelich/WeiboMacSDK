//
//  WeiboConcreteStatusesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboConcreteStatusesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboRequestError.h"
#import "LocalAutocompleteDB.h"

#import "WTCallback.h"
#import "NSArray+WeiboAdditions.h"

NSString * const WeiboStatusStreamDidReceiveNewStatusesNotificationKey = @"WeiboStatusStreamDidReceiveNewStatusesNotificationKey";
NSString * const WeiboStatusStreamDidReceiveRequestErrorNotificationKey = @"WeiboStatusStreamDidReceiveRequestErrorNotificationKey";
NSString * const WeiboStatusStreamDidRemoveStatusNotificationKey = @"WeiboStatusStreamDidRemoveStatusNotificationKey";

NSString * const WeiboStatusStreamNotificationStatusesArrayKey = @"WeiboStatusStreamNotificationStatusesArrayKey";
NSString * const WeiboStatusStreamNotificationRequestErrorKey = @"WeiboStatusStreamNotificationRequestErrorKey";
NSString * const WeiboStatusStreamNotificationBaseStatusKey = @"WeiboStatusStreamNotificationBaseStatusKey";
NSString * const WeiboStatusStreamNotificationStatusIndexKey = @"WeiboStatusStreamNotificationStatusIndexKey";
NSString * const WeiboStatusStreamNotificationAddingTypeKey = @"WeiboStatusStreamNotificationAddingTypeKey";

@interface WeiboConcreteStatusesStream ()
- (NSUInteger)statuseIndex:(WeiboBaseStatus *)theStatus;
- (void)_deleteStatus:(WeiboBaseStatus *)theStatus;
- (void)_loadNewer;
- (void)_loadOlder;
- (void)_loadBeforeGap:(NSString *)gap;
- (void)_readFromDisk;
- (void)_writeToDisk;
- (void)_postError:(WeiboRequestError *)error;

- (void)statusesResponse:(id)response couldBeGap:(BOOL)beGap isFromFillingInGap:(BOOL)fillingGap;
- (void)loadNewerResponse:(id)response info:(id)info;
- (void)loadOlderResponse:(id)response info:(id)info;
- (void)fillInGapResponse:(id)response info:(id)info;

- (WTCallback *)loadNewerResponseCallback;
- (WTCallback *)loadOlderResponseCallback;
- (WTCallback *)fillInGapResponseCallback:(id)info;

@end

@implementation WeiboConcreteStatusesStream

#pragma mark -
#pragma mark Life Cycle
- (id)init{
    if (self = [super init]) {
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(deleteStatusNotification:) name:kWeiboStatusDeleteNotification object:nil];
        [center addObserver:self selector:@selector(weiboObjectWillDeallocNotification:) name:WeiboObjectWithIdentifierWillDeallocNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [statuses release]; statuses = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors
- (NSString *)guid{
    return guid;
}
- (NSMutableArray *)statuses{
    if (!statuses) {
        statuses = [[NSMutableArray alloc] init];
    }
    return statuses;
}
- (void)setStatuses:(NSArray *)newStatuses{
    NSMutableArray * mutableStatuses = [NSMutableArray arrayWithArray:newStatuses];
    [statuses release];
    statuses = [mutableStatuses retain];
}
- (void)addStatus:(WeiboBaseStatus *)newStatus{
    NSArray * array = [NSArray arrayWithObject:newStatus];
    [self addStatuses:array withType:WeiboStatusesAddingTypePrepend];
}
- (void)addStatuses:(NSArray *)newStatuses{
    [self addStatuses:newStatuses withType:WeiboStatusesAddingTypePrepend];
}
- (void)addStatuses:(NSArray *)newStatuses withType:(WeiboStatusesAddingType)type{
    BOOL shouldPostNotification = YES;//[self hasData];
    // prepend can keep scroll position at top, 
    // for some subclass that can NOT load newer, 
    // load older has a append effect,
    // so we should force to prepend if there is no data yet.
    BOOL shouldForceToAppend = ![self hasData];
    
    switch (type) {
        case WeiboStatusesAddingTypeAppend:{
            if ([newStatuses count] == 0) {
                [self markAtEnd];
            }
            [[self statuses] addObjectsFromArray:newStatuses];
            break;
        }
        case WeiboStatusesAddingTypePrepend:{
            NSRange insertRange = NSMakeRange(0, [newStatuses count]);
            NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:insertRange];
            [statuses insertObjects:newStatuses atIndexes:indexes];
            break;
        }
        case WeiboStatusesAddingTypeGap:{
            // TODO: Find gap and insert new statuses to gap.
            break;
        }
        default:
            break;
    }
    [self noticeDidReceiveNewStatuses:newStatuses withAddingType:shouldForceToAppend?WeiboStatusesAddingTypeAppend:type];
    
    if (shouldPostNotification) {
        [self postStatusesChangedNotification];
    }
    
    if ([self shouldIndexUsersInAutocomplete]) {
        [[LocalAutocompleteDB sharedAutocompleteDB] assimilateFromStatuses:newStatuses];
    }
}
- (void)_deleteStatus:(WeiboBaseStatus *)theStatus{
    NSInteger index = [self statuseIndex:theStatus];
    if (index < 0) {
        return;
    }    
    if (index >= [[self statuses] count]) {
        return;
    }
    [theStatus retain];
    [[self statuses] removeObjectAtIndex:index];
    
    [self noticeDidRemoveStatus:[theStatus autorelease] atIndex:index];
}
- (NSUInteger)statuseIndex:(WeiboBaseStatus *)theStatus{
    return [statuses indexOfObject:theStatus];
}
- (NSUInteger)statuseIndexByID:(WeiboStatusID)theID{
    WeiboBaseStatus * temp = [[WeiboBaseStatus alloc] init];
    temp.sid = theID;
    NSUInteger index = [self statuseIndex:temp];
    [temp release];
    return index;
}
- (WeiboBaseStatus *)newestStatus{
    if (self.statuses.count > 1)
    {
        // Workaround for users that has a weibo stick on top.
        
        WeiboBaseStatus * first = self.statuses[0];
        WeiboBaseStatus * second = self.statuses[1];
        
        if (first.createdAt >= second.createdAt)
        {
            return first;
        }
        return second;
    }
    else
    {
        return [[self statuses] firstObject]; 
    }
}
- (WeiboBaseStatus *)oldestStatus{
    return [[self statuses] lastObject];
}
- (WeiboStatusID)newestStatusID{
    if ([self newestStatus]) {
        return [self newestStatus].sid;
    }
    return 0;
}
- (WeiboStatusID)oldestStatusID{
    if ([self oldestStatus]) {
        return [self oldestStatus].sid;
    }
    return 0;
}
- (NSDate *)lastUpdated{
    return lastUpdated;
}
- (NSUInteger)maxCount{
    return 500;
}
- (NSUInteger)minStatusesToConsiderBeingGap{
    return 5;
}
- (BOOL)shouldIndexUsersInAutocomplete{
    return NO;
}
- (BOOL)isLoadingNewer{
    return _flags.isLoadingNewer;
}
- (NSString *)autosaveName{
    return @"statuses/";
}
- (BOOL)isStreamEnded{
    return _flags.isAtEnd;
}


#pragma mark -
#pragma mark Network Connecting
- (void)_loadNewer{
    
}
- (void)loadNewer{
    if (_flags.isLoadingNewer) {
        return;
    }
    if (![self canLoadNewer]) {
        return;
    }
    _flags.isLoadingNewer = YES;
    [self _loadNewer];
}
- (void)_loadOlder{
    
}
- (void)loadOlder{
    if (_flags.isLoadingNewer || _flags.isAtEnd ||  _flags.isLoadingOlder) {
        return;
    }
    if ([[self statuses] count] > [self maxCount]) {
        [self markAtEnd];
        return;
    }
    _flags.isLoadingOlder = YES;
    [self _loadOlder];
}
- (void)retryLoadOlder{
    _flags.isAtEnd = NO;
    [self loadOlder];
}
- (void)_loadBeforeGap:(NSString *)gap{
    
}
- (void)fillInGap:(NSString *)gap{
    
}

- (void)statusesResponse:(id)response couldBeGap:(BOOL)beGap isFromFillingInGap:(BOOL)fillingGap{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        [self noticeDidReceiveRequestError:response];
        return;
    }
    if (fillingGap) {
        [self addStatuses:response withType:WeiboStatusesAddingTypeGap];
    }
    else if (beGap) {
        [self addStatuses:response withType:WeiboStatusesAddingTypePrepend];
    }else {
        [self addStatuses:response withType:WeiboStatusesAddingTypeAppend];
    }
}
- (void)loadNewerResponse:(id)response info:(id)info{
    _flags.isLoadingNewer = NO;
    [self statusesResponse:response couldBeGap:YES isFromFillingInGap:NO];
}
- (void)loadOlderResponse:(id)response info:(id)info{
    _flags.isLoadingOlder = NO;
    [self statusesResponse:response couldBeGap:NO isFromFillingInGap:NO];
}
- (void)fillInGapResponse:(id)response info:(id)info{
    [self statusesResponse:response couldBeGap:YES isFromFillingInGap:YES];
}

- (WTCallback *)loadNewerResponseCallback{
    return WTCallbackMake(self, @selector(loadNewerResponse:info:), nil);
}
- (WTCallback *)loadOlderResponseCallback{
    return WTCallbackMake(self, @selector(loadOlderResponse:info:), nil);
}
- (WTCallback *)fillInGapResponseCallback:(id)info{
    return WTCallbackMake(self, @selector(fillInGapResponse:info:), info);
}


#pragma mark -
#pragma mark On Disk Caching ( Not Implemented Yet )
- (void)_readFromDisk{}
- (void)_writeToDisk{}
- (NSString *)storedStreamPath{
    return nil;
}
- (void)saveStream{}


#pragma mark -
#pragma mark Others

- (void)markAtEnd{
    _flags.isAtEnd = YES;
}
- (void)_postError:(WeiboRequestError *)error{
    
}
- (void)deleteStatusNotification:(NSNotification *)notification{
    WeiboBaseStatus * status = notification.object;
    [self _deleteStatus:status];
}
- (void)weiboObjectWillDeallocNotification:(NSNotification *)notification
{
    NSString * identifier = notification.userInfo[WeiboObjectUserInfoUniqueIdentifierKey];
    
    if (!identifier)
    {
        return;
    }
    
    for (WeiboBaseStatus * status in self.statuses)
    {
        [status removeLayoutCacheWithIdentifier:identifier];
    }
}

- (void)postStatusesChangedNotification{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kWeiboStreamStatusChangedNotification object:self];
}

- (void)noticeDidReceiveNewStatuses:(NSArray *)newStatuses withAddingType:(WeiboStatusesAddingType)type
{
    NSDictionary * userInfo = @{WeiboStatusStreamNotificationStatusesArrayKey : newStatuses,
                                WeiboStatusStreamNotificationAddingTypeKey : [NSNumber numberWithInteger:type]};
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboStatusStreamDidReceiveNewStatusesNotificationKey object:self userInfo:userInfo];
}
- (void)noticeDidReceiveRequestError:(WeiboRequestError *)error
{
    NSDictionary * userInfo = @{WeiboStatusStreamNotificationRequestErrorKey : error};
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboStatusStreamDidReceiveRequestErrorNotificationKey object:self userInfo:userInfo];
}
- (void)noticeDidRemoveStatus:(WeiboBaseStatus *)status atIndex:(NSInteger)index
{
    NSDictionary * userInfo = @{WeiboStatusStreamNotificationBaseStatusKey : status,
                                WeiboStatusStreamNotificationStatusIndexKey : [NSNumber numberWithInteger:index]};
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboStatusStreamDidRemoveStatusNotificationKey object:self userInfo:userInfo];
}

@end
