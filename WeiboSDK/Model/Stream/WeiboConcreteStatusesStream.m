//
//  WeiboConcreteStatusesStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboConcreteStatusesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboDummyGapStatus.h"
#import "WeiboStatusFilter.h"
#import "WeiboRequestError.h"
#import "LocalAutocompleteDB.h"

#import "WeiboCallback.h"
#import "NSArray+WeiboAdditions.h"
#import "NSObject+AssociatedObject.h"

NSString * const WeiboStatusStreamDidReceiveNewStatusesNotificationKey = @"WeiboStatusStreamDidReceiveNewStatusesNotificationKey";
NSString * const WeiboStatusStreamDidReceiveRequestErrorNotificationKey = @"WeiboStatusStreamDidReceiveRequestErrorNotificationKey";
NSString * const WeiboStatusStreamDidRemoveStatusNotificationKey = @"WeiboStatusStreamDidRemoveStatusNotificationKey";

NSString * const WeiboStatusStreamNotificationStatusesArrayKey = @"WeiboStatusStreamNotificationStatusesArrayKey";
NSString * const WeiboStatusStreamNotificationRequestErrorKey = @"WeiboStatusStreamNotificationRequestErrorKey";
NSString * const WeiboStatusStreamNotificationBaseStatusKey = @"WeiboStatusStreamNotificationBaseStatusKey";
NSString * const WeiboStatusStreamNotificationStatusIndexKey = @"WeiboStatusStreamNotificationStatusIndexKey";
NSString * const WeiboStatusStreamNotificationAddingTypeKey = @"WeiboStatusStreamNotificationAddingTypeKey";

@interface WeiboConcreteStatusesStream ()
{
    NSMutableArray * statuses;
    struct {
		unsigned int isLoadingNewer:1;
		unsigned int isLoadingOlder:1;
        unsigned int isAtEnd:1;
        unsigned int shouldAutoClearUp:1;
        unsigned int isKeyStream:1;
	} _flags;
}

// statuses filterd by -[self statusFilters];
@property (nonatomic, strong) NSMutableArray * invalidStatuses;

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

- (WeiboCallback *)loadNewerResponseCallback;
- (WeiboCallback *)loadOlderResponseCallback;
- (WeiboCallback *)fillInGapResponseCallback:(id)info;

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _loadNewerError = nil;
    _loadOlderError = nil;
    _invalidStatuses = nil;
     statuses = nil;
}


#pragma mark -
#pragma mark Accessors

- (NSMutableArray *)statuses
{
    if (!statuses) {
        statuses = [[NSMutableArray alloc] init];
    }
    return statuses;
}
- (void)setStatuses:(NSArray *)newStatuses{
    NSMutableArray * mutableStatuses = [NSMutableArray arrayWithArray:newStatuses];
    statuses = mutableStatuses;
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
    
    if (!self.hasData)
    {
        type = WeiboStatusesAddingTypeAppend;
    }
    
    NSMutableArray * statusesToAdd = [newStatuses mutableCopy];
    
    for (WeiboBaseStatus * status in self.statuses)
    {
        [statusesToAdd removeObject:status];
    }
    
    switch (type) {
        case WeiboStatusesAddingTypeAppend:{
            _flags.isAtEnd = statusesToAdd.count == 0;
            [[self statuses] addObjectsFromArray:statusesToAdd];
            break;
        }
        case WeiboStatusesAddingTypePrepend:{
            NSRange insertRange = NSMakeRange(0, [statusesToAdd count]);
            NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:insertRange];
            [statuses insertObjects:statusesToAdd atIndexes:indexes];
            break;
        }
        case WeiboStatusesAddingTypeGap:{
            // TODO: Find gap and insert new statuses to gap.
            break;
        }
        default:
            break;
    }
    
    NSInteger topStatusCount = 0;
    for (WeiboBaseStatus * status in self.statuses)
    {
        if (status.isTopStatus) {
            topStatusCount++;
        } else {
            break;
        }
    }
    _topStatusesCount = topStatusCount;
    
    [self noticeDidReceiveNewStatuses:statusesToAdd withAddingType:type];
    
    if (shouldPostNotification) {
        [self postStatusesChangedNotification];
    }
    
    if ([self shouldIndexUsersInAutocomplete]) {
        [[LocalAutocompleteDB sharedAutocompleteDB] assimilateFromStatuses:statusesToAdd];
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
    [[self statuses] removeObjectAtIndex:index];
    
    [self noticeDidRemoveStatus:theStatus atIndex:index];
}
- (NSUInteger)statuseIndex:(WeiboBaseStatus *)theStatus{
    return [statuses indexOfObject:theStatus];
}
- (NSUInteger)statuseIndexByID:(WeiboStatusID)theID{
    WeiboBaseStatus * temp = [[WeiboBaseStatus alloc] init];
    temp.sid = theID;
    NSUInteger index = [self statuseIndex:temp];
    return index;
}
- (WeiboBaseStatus *)newestStatusFromArray:(NSArray *)array
{
    if (array.count > 1)
    {
        // Workaround for users that has a weibo stick on top.
        
        WeiboBaseStatus * first = array[0];
        WeiboBaseStatus * second = array[1];
        
        if (first.createdAt >= second.createdAt)
        {
            return first;
        }
        return second;
    }
    else
    {
        return [array firstObject];
    }
}
- (WeiboBaseStatus *)newestStatus
{
    WeiboBaseStatus * newestValidStatus = [self newestStatusFromArray:self.statuses];
    WeiboBaseStatus * newestInvalidStatus = [self newestStatusFromArray:self.invalidStatuses];
    
    if (newestValidStatus && newestInvalidStatus)
    {
        return (newestValidStatus.sid > newestInvalidStatus.sid) ? newestValidStatus : newestInvalidStatus;
    }
    else if (newestInvalidStatus)
    {
        return newestInvalidStatus;
    }
    else
    {
        return newestValidStatus;
    }
    
}
- (WeiboBaseStatus *)oldestStatusFromArray:(NSArray *)array
{
    return [array lastObject];
}
- (WeiboBaseStatus *)oldestStatus
{
    WeiboBaseStatus * oldestValidStatus = [self oldestStatusFromArray:self.statuses];
    WeiboBaseStatus * oldestInvalidStatus = [self oldestStatusFromArray:self.invalidStatuses];
    
    if (oldestValidStatus && oldestInvalidStatus)
    {
        return (oldestValidStatus.sid < oldestInvalidStatus.sid) ? oldestValidStatus : oldestInvalidStatus;
    }
    else if (oldestInvalidStatus)
    {
        return oldestInvalidStatus;
    }
    else
    {
        return oldestValidStatus;
    }
}
- (WeiboStatusID)newestStatusID
{
    if ([self newestStatus])
    {
        return [self newestStatus].sid;
    }
    return 0;
}
- (WeiboStatusID)oldestStatusID
{
    if ([self oldestStatus])
    {
        return [self oldestStatus].sid;
    }
    return 0;
}
- (NSUInteger)maxCount
{
    return 500;
}
- (NSUInteger)minStatusesToConsiderBeingGap
{
    return 5;
}
- (BOOL)shouldIndexUsersInAutocomplete
{
    return NO;
}
- (BOOL)isLoadingNewer
{
    return _flags.isLoadingNewer;
}
- (NSString *)autosaveName
{
    return @"statuses/";
}
- (BOOL)isStreamEnded
{
    return _flags.isAtEnd;
}
- (BOOL)appliesStatusFilter
{
    return NO;
}

- (void)updateViewedMostRecentID
{
    WeiboBaseStatus * lastSeened = nil;
    
    for (WeiboBaseStatus * status in self.statuses)
    {
        if (status.wasSeen)
        {
            lastSeened = status;
            break;
        }
    }
    
    if (lastSeened.sid > self.viewedMostRecentID)
    {
        self.viewedMostRecentID = lastSeened.sid;
    }
}

- (WeiboBaseStatus *)viewedMostRecentStatus
{
    [self updateViewedMostRecentID];
    
    if (!self.viewedMostRecentID) return nil;
    
    return [self statusWithID:self.viewedMostRecentID];
}

- (WeiboBaseStatus *)statusWithID:(WeiboStatusID)sid
{
    for (WeiboBaseStatus * status in self.statuses)
    {
        if (status.sid == sid) return status;
    }
    return nil;
}

- (NSInteger)unreadCount
{
    WeiboBaseStatus * topStatus = [self viewedMostRecentStatus];
    
    if (!topStatus) return 0;
    
    NSInteger count = [statuses indexOfObject:topStatus];
    
    count -= [self topStatusesCount]; // 置顶微博不进行计算
    
    return count;
}

- (void)markStatusWithIDAsRead:(WeiboStatusID)statusID
{
    WeiboBaseStatus * topStatus = [self viewedMostRecentStatus];
    WeiboBaseStatus * statusToMark = [self statusWithID:statusID];
    
    NSInteger viewedMostRecentIndex = [statuses indexOfObject:topStatus];
    NSInteger indexToMark = [self statuseIndex:statusToMark];
    
    if (indexToMark == viewedMostRecentIndex + 1)
    {
        statusToMark.wasSeen = YES;
        self.viewedMostRecentID = statusID;
    }
}

#pragma mark -
#pragma mark Network Connecting
- (void)_loadNewer
{
    
}
- (void)loadNewer
{
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

- (void)statusesResponse:(id)response couldBeGap:(BOOL)couldBeGap isFromFillingInGap:(BOOL)fillingGap
{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        if (fillingGap)
        {
            // Filling Gap
            // TODO: set filling gap error
        }
        else if (couldBeGap)
        {
            // Prepend, Loading Newer
            self.loadNewerError = response;
        }
        else
        {
            // Append, Loading Older
            self.loadOlderError = response;
        }
        
        [self noticeDidReceiveRequestError:response];
        return;
    }
    
    if (fillingGap)
    {
        [self addStatuses:response withType:WeiboStatusesAddingTypeGap];
    }
    else if (couldBeGap)
    {
        [self setLoadNewerError:nil];
        [self addStatuses:response withType:WeiboStatusesAddingTypePrepend];
    }
    else
    {
        _loadOlderSuccessTimes++;
        
        [self setLoadOlderError:nil];
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

- (WeiboCallback *)loadNewerResponseCallback
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(loadNewerResponse:info:), nil);
    return [self filteringCallbackWithCallback:callback];
}
- (WeiboCallback *)loadOlderResponseCallback
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(loadOlderResponse:info:), nil);
    return [self filteringCallbackWithCallback:callback];
}
- (WeiboCallback *)fillInGapResponseCallback:(id)info
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(fillInGapResponse:info:), info);
    return [self filteringCallbackWithCallback:callback];
}

#pragma mark - Filtering

- (WeiboCallback *)filteringCallbackWithCallback:(WeiboCallback *)actualCallback
{
    if (self.appliesStatusFilter)
    {
        return WeiboCallbackMake(self, @selector(filterResponse:info:), actualCallback);
    }
    return actualCallback;
}
- (void)filterResponse:(id)response info:(id)info
{
    WeiboCallback * callback = (WeiboCallback *)info;
    
    if (![callback isKindOfClass:[WeiboCallback class]]) return;
    
    if (![response isKindOfClass:[NSArray class]])
    {
        [callback invoke:response];
        return;
    }
    
    NSArray * statusFilters = [self statusFilters];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSMutableArray * remainingStatuses = [NSMutableArray array];
        NSMutableArray * invalidStatuses = [NSMutableArray array];
        
        for (WeiboBaseStatus * status in response)
        {
            BOOL invalid = NO;
            for (WeiboStatusFilter * filter in statusFilters)
            {
                if ([filter validateStatus:status])
                {
                    invalid = YES;
                    break;
                }
            }
            
            if (invalid)
            {
                [invalidStatuses addObject:status];
            }
            else
            {
                [remainingStatuses addObject:status];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addInvalidStatuses:invalidStatuses];
            [callback invoke:remainingStatuses];
        });
    });
}

- (void)addInvalidStatuses:(NSArray *)statusesArray
{
    if (!statusesArray.count) return;
    
    WeiboBaseStatus * newestInvalidStatus = [self newestStatusFromArray:self.invalidStatuses];
    WeiboBaseStatus * oldestInvalidStatus = [self oldestStatusFromArray:self.invalidStatuses];
    
    WeiboBaseStatus * start = [self newestStatusFromArray:statusesArray];
    WeiboBaseStatus * end = [self oldestStatusFromArray:statusesArray];
    
    if (start.sid <= oldestInvalidStatus.sid)
    {
        // append
        
        [self.invalidStatuses addObjectsFromArray:statusesArray];
    }
    else if (end.sid >= newestInvalidStatus.sid)
    {
        // prepend
        
        [self.invalidStatuses insertObjects:statusesArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statusesArray.count)]];
    }
    else
    {
        // should never goes here.
        
        [self.invalidStatuses addObjectsFromArray:statusesArray];
    }
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

- (void)markAtEnd
{
    _flags.isAtEnd = YES;
}
- (void)_postError:(WeiboRequestError *)error
{
    
}
- (void)deleteStatusNotification:(NSNotification *)notification
{
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
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(type), WeiboStatusStreamNotificationAddingTypeKey, newStatuses, WeiboStatusStreamNotificationStatusesArrayKey, nil];

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

- (NSArray *)statusFilters
{
    return nil;
}

@end
