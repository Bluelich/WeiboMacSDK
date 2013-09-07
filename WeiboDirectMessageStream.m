//
//  WeiboDirectMessageStream.m
//  Weibo
//
//  Created by Wutian on 13-9-4.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboDirectMessageStream.h"
#import "WTCallback.h"
#import "WeiboRequestError.h"

NSString * const WeiboDirectMessageStreamDidUpdateNotification = @"WeiboDirectMessageStreamDidUpdateNotification";

@interface WeiboDirectMessageStream ()
{
    NSMutableArray * _messages;
    struct {
        unsigned int isLoadingNewer:1;
        unsigned int isLoadingOlder:1;
        unsigned int isAtEnd:1;
    } _flags;
}

@end

@implementation WeiboDirectMessageStream

- (void)dealloc
{
    [_messages release], _messages = nil;
    
    [super dealloc];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (NSArray *)messages
{
    return _messages;
}

- (BOOL)forceReadBit
{
    return NO;
}

- (WeiboMessageID)newestMessageID
{
    return [[_messages lastObject] messageID];
}
- (WeiboMessageID)oldestMessageID
{
    return [[_messages firstObject] messageID];
}

- (void)messagesResponse:(id)response info:(id)info
{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        
    }
    else if ([response isKindOfClass:[NSArray class]])
    {
        [self addMessages:response];
    }
}

- (void)_loadNewer
{
    
}
- (void)_loadOlder
{
    
}

- (void)loadNewer
{
    if (_flags.isLoadingNewer) return;
    
    [self _loadNewer];
    
    _flags.isLoadingNewer = YES;
}
- (void)loadOlder
{
    if (_flags.isLoadingOlder) return;
    
    [self _loadOlder];
    
    _flags.isLoadingNewer = YES;
}

- (void)loadNewerResponse:(id)response info:(id)info
{
    _flags.isLoadingNewer = NO;
    
    [self messagesResponse:response info:info];
}
- (void)loadOlderResponse:(id)response info:(id)info
{
    _flags.isLoadingOlder = NO;
    
    [self messagesResponse:response info:info];
}

- (WTCallback *)loadNewerResponseCallback
{
    return WTCallbackMake(self, @selector(loadNewerResponse:info:), nil);
}

- (WTCallback *)loaderOlderResponseCallback
{
    return WTCallbackMake(self, @selector(loadOlderResponse:info:), nil);
}

- (void)addMessages:(NSArray *)messages
{
    BOOL readBit = [self forceReadBit];
    
    for (WeiboDirectMessage * message in messages)
    {
        NSInteger idx = [_messages indexOfObject:message inSortedRange:NSMakeRange(0, _messages.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(WeiboDirectMessage * obj1, WeiboDirectMessage * obj2) {
            return [obj1 compare:obj2];
        }];
        
        [_messages insertObject:message atIndex:idx];
        
        if (readBit) message.read = YES;
    }
    
    if (messages.count)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDirectMessageStreamDidUpdateNotification object:self];
    }
}
- (void)deleteMessage:(WeiboDirectMessage *)message
{
    
}

@end
