//
//  WeiboAccount.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"
#import "WeiboAPI.h"
#import "WeiboUser.h"
#import "WeiboUnread.h"
#import "WeiboRequestError.h"
#import "WeiboStream.h"
#import "WeiboTimelineStream.h"
#import "WeiboMentionsStream.h"
#import "WeiboCommentsTimelineStream.h"
#import "WeiboUserTimelineStream.h"
#import "WeiboRepliesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboComment.h"
#import "NSArray+WeiboAdditions.h"
#import "WTCallback.h"
#import "WTFoundationUtilities.h"
#import "SSKeychain.h"

#define WEIBO_APIROOT_V1 @"http://api.t.sina.com.cn/"
#define WEIBO_APIROOT_V2 @"https://api.weibo.com/2/"
#define WEIBO_APIROOT_DEFAULT WEIBO_APIROOT_V1

@implementation WeiboAccount
@synthesize username, password, oAuthToken, oAuthTokenSecret, user, apiRoot;
@synthesize delegate = _delegate, notificationOptions;

#pragma mark -
#pragma mark Life Cycle
- (id)init{
    if (self = [super init]) {
        notificationOptions = WeiboTweetNotificationMenubar | WeiboMentionNotificationMenubar |
                              WeiboFollowerNotificationMenubar | WeiboCommentNotificationMenubar | 
                              WeiboDirectMessageNotificationMenubar;
        timelineStream = [[WeiboTimelineStream alloc] init];
        timelineStream.account = self;
        mentionsStream = [[WeiboMentionsStream alloc] init];
        mentionsStream.account = self;
        commentsTimelineStream = [[WeiboCommentsTimelineStream alloc] init];
        commentsTimelineStream.account = self;

        usersByUsername = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:oAuthToken forKey:@"oauth-token"];
    [encoder encodeObject:apiRoot forKey:@"api-root"];
    [encoder encodeInteger:notificationOptions forKey:@"notification-options"];
    NSLog(@"saving");
    LogBinary(notificationOptions,16);
    [encoder encodeObject:user forKey:@"user"];
}
- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [self init]) {
        username = [[decoder decodeObjectForKey:@"username"] retain];
        self.oAuthToken = [decoder decodeObjectForKey:@"oauth-token"];
        self.oAuthTokenSecret = [SSKeychain passwordForService:[self keychainService] 
                                                       account:self.oAuthToken];
        apiRoot = [[decoder decodeObjectForKey:@"api-root"] retain];
        notificationOptions = [decoder decodeIntegerForKey:@"notification-options"];
        NSLog(@"loading");
        LogBinary(notificationOptions,16);
        self.user = [decoder decodeObjectForKey:@"user"];
        [self verifyCredentials:nil];
    }
    return self;
}
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword apiRoot:(NSString *)root{
    if ((self = [self init])) {
        username = [aUsername retain];
        password = aPassword;
        apiRoot  = [root retain];
    }
    return self;
}
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword{
    return [self initWithUsername:aUsername password:aPassword apiRoot:WEIBO_APIROOT_DEFAULT];
}
- (void)dealloc{
    [username release]; 
    [apiRoot release];
    [oAuthToken release];
    [oAuthTokenSecret release];
    [user release];
    [usersByUsername release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor
- (WeiboTimelineStream *) timelineStream{
    return timelineStream;
}
- (WeiboMentionsStream *) mentionsStream{
    return mentionsStream;
}
- (WeiboCommentsTimelineStream *) commentsTimelineStream{
    return commentsTimelineStream;
}

#pragma mark -
#pragma mark Core Methods
- (NSString *)keychainService{
    NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return identifier;
}                                                            
- (BOOL)isEqualToAccount:(WeiboAccount *)anotherAccount{
    return [self.username isEqualToString:anotherAccount.username];
}
- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToAccount:object];
    }
    return NO;
}
- (WeiboAPI *)request:(WTCallback *)callback{
    return [WeiboAPI requestWithAPIRoot:self.apiRoot callback:callback];
}
- (WeiboAPI *)authenticatedRequest:(WTCallback *)callback{
    return [WeiboAPI authenticatedRequestWithAPIRoot:self.apiRoot account:self callback:callback];
}

#pragma mark -
#pragma mark Timeline
- (void)forceRefreshTimelines{
    [timelineStream loadNewer];
    [mentionsStream loadNewer];
    [commentsTimelineStream loadNewer];
}
- (void)refreshTimelineForType:(WeiboCompositionType)type{
    switch (type) {
        case WeiboCompositionTypeStatus:
            [timelineStream loadNewer];
            break;
        case WeiboCompositionTypeComment:
            //[commentsTimelineStream loadNewer];
            break;
        default:
            break;
    }
}
- (void)refreshTimelines{
    WTCallback * callback = WTCallbackMake(self, @selector(unreadCountResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api unreadCountSinceID:[timelineStream newestStatusID]];
    if ([_delegate respondsToSelector:@selector(account:didCheckingUnreadCount:)]) {
        [_delegate account:self didCheckingUnreadCount:nil];
    }
}
- (void)unreadCountResponse:(id)response info:(id)info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        return ;
    }
    NSLog(@"%@",response);
    WeiboUnread * unread = (WeiboUnread *)response;
    if (unread.newStatus > 0) {
        [timelineStream loadNewer];
    }
    if (unread.newMentions > 0) {
        [mentionsStream loadNewer];
        [self resetUnreadCountWithType:WeiboUnreadCountTypeMention];
    }
    if (unread.newComments > 0) {
        [commentsTimelineStream loadNewer];
        [self resetUnreadCountWithType:WeiboUnreadCountTypeComment];
    }
    if (unread.newDirectMessages > 0) {
        [self setHasNewDirectMessages:YES];
        // have NOT get access to DM api yet, just post a notification
    }
    if (unread.newFollowers > 0) {
        [self setHasNewFollowers:YES];
        // Follower list not implemented yet.
        
    }
    if ([_delegate respondsToSelector:@selector(account:finishCheckingUnreadCount:)]) {
        [_delegate account:self finishCheckingUnreadCount:unread];
    }
}
- (void)resetUnreadCountWithType:(WeiboUnreadCountType)type{
    WTCallback * callback = WTCallbackMake(self, @selector(unreadCountResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api resetUnreadWithType:type];
    
    // may remove in further update.
    if (type == WeiboUnreadCountTypeDirectMessage) {
        [self setHasNewDirectMessages:NO];
    }
    if (type == WeiboUnreadCountTypeFollower) {
        [self setHasNewFollowers:NO];
    }
}

#pragma mark -
#pragma mark Composition

#pragma mark -
#pragma mark User
- (void)userWithUsername:(NSString *)screenname callback:(WTCallback *)aCallback{
    WeiboUser * cachedUser = [usersByUsername objectForKey:screenname];
    if (cachedUser) {
        [self userResponse:cachedUser info:aCallback];
    }else {
        WTCallback * callback = WTCallbackMake(self, @selector(userResponse:info:), aCallback);
        WeiboAPI * api = [self authenticatedRequest:callback];
        [api userWithUsername:screenname];
    }
}
- (void)userResponse:(id)response info:(id)info{
    WTCallback * callback = (WTCallback *)info;
    WeiboUser * newUser = (WeiboUser *)response;
    [usersByUsername setObject:newUser forKey:newUser.screenName];
    [callback invoke:response];
}

#pragma mark -
#pragma mark Account
- (void)_postAccountDidUpdateNotification{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kWeiboAccountDidUpdateNotification object:self];
}
- (void)myUserResponse:(id)response info:(id)info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        
    }else {
        WeiboUser * newUser = (WeiboUser *)response;
        self.user = newUser;
        [self myUserDidUpdate:newUser];
    }
    [(WTCallback *)info invoke:self];
}
- (void)myUserDidUpdate:(WeiboUser *)user{
    [self _postAccountDidUpdateNotification];
}
- (void)verifyCredentials:(WTCallback *)aCallback{
    WTCallback * callback = WTCallbackMake(self, @selector(myUserResponse:info:), aCallback);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api verifyCredentials];
}

#pragma mark -
#pragma mark User Detail Streams
- (NSCache *)_userDetailsStreamCache{
    if (!userDetailsStreamsCache) {
        userDetailsStreamsCache = [[NSCache alloc] init];
    }
    return userDetailsStreamsCache;
}
- (id)_cachedStream:(NSString *)key{
    return [[self _userDetailsStreamCache] objectForKey:key];
}
- (WeiboUserTimelineStream *)timelineStreamForUser:(WeiboUser *)aUser{
    NSString * key = [NSString stringWithFormat:@"%@/timeline",aUser.screenName];
    WeiboUserTimelineStream * stream = [self _cachedStream:key];
    if (!stream) {
        stream = [[WeiboUserTimelineStream alloc] init];
        [stream setAccount:self];
        [stream setUser:aUser];
        [userDetailsStreamsCache setObject:stream forKey:key];
        [stream release];
    }
    return stream;
}
- (void)pruneUserDetailStreamCache{
}

#pragma mark - Others
- (WeiboRepliesStream *)repliesStreamForStatus:(WeiboStatus *)status{
    // No cache here yet.
    WeiboRepliesStream * stream = [[WeiboRepliesStream alloc] init];
    [stream setBaseStatus:status];
    [stream setAccount:self];
    return [stream autorelease];
}
- (BOOL)hasFreshTweets{
    WeiboBaseStatus * topStatus = [timelineStream newestStatus];
    if (!topStatus) {
        return NO;
    }
    return !topStatus.wasSeen;
}
- (BOOL)hasFreshMentions{
    WeiboBaseStatus * topStatus = [mentionsStream newestStatus];
    if (!topStatus) {
        return NO;
    }
    return !topStatus.wasSeen;
}
- (BOOL)hasFreshComments{
    WeiboBaseStatus * topStatus = [commentsTimelineStream newestStatus];
    if (!topStatus) {
        return NO;
    }
    return !topStatus.wasSeen;
}
- (BOOL)hasFreshDirectMessages{
    return _notificationFlags.newDirectMessages;
}
- (BOOL)hasNewFollowers{
    return _notificationFlags.newFollowers;
}
- (BOOL)hasAnythingUnread{
    return [self hasFreshTweets] || [self hasFreshMentions] || [self hasFreshComments] || [self hasFreshDirectMessages] || [self hasNewFollowers];
}
- (BOOL)hasFreshAnythingApplicableToStatusItem{
    if ((notificationOptions & WeiboTweetNotificationMenubar) && [self hasFreshTweets]) {
        return YES;
    }
    if ((notificationOptions & WeiboMentionNotificationMenubar) && [self hasFreshMentions]) {
        return YES;
    }
    if ((notificationOptions & WeiboCommentNotificationMenubar) && [self hasFreshComments]) {
        return YES;
    }
    if ((notificationOptions & WeiboDirectMessageNotificationMenubar) && [self hasFreshDirectMessages]) {
        return YES;
    }
    if ((notificationOptions & WeiboFollowerNotificationMenubar) && [self hasNewFollowers]) {
        return YES;
    }
    return NO;
    // need alter.
}
- (BOOL)hasFreshAnythingApplicableToDockBadge{
    if ((notificationOptions & WeiboTweetNotificationBadge) && [self hasFreshTweets]) {
        return YES;
    }
    if ((notificationOptions & WeiboMentionNotificationBadge) && [self hasFreshMentions]) {
        return YES;
    }
    if ((notificationOptions & WeiboCommentNotificationBadge) && [self hasFreshComments]) {
        return YES;
    }
    if ((notificationOptions & WeiboDirectMessageNotificationBadge) && [self hasFreshDirectMessages]) {
        return YES;
    }
    if ((notificationOptions & WeiboFollowerNotificationBadge) && [self hasNewFollowers]) {
        return YES;
    }
    return NO;
    // need alter.
}
- (void)deleteStatus:(WeiboBaseStatus *)status{
    WeiboAPI * api = [self authenticatedRequest:nil];
    if ([status isKindOfClass:[WeiboStatus class]]) {
        [api destoryStatus:status.sid];
    }else if ([status isKindOfClass:[WeiboComment class]]) {
        [api destoryComment:status.sid];
    }else {
        return;
    }
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kWeiboStatusDeleteNotification object:status];
}

- (void)setHasNewDirectMessages:(BOOL)hasNew{
    _notificationFlags.newDirectMessages = hasNew;
}
- (void)setHasNewFollowers:(BOOL)hasNew{
    _notificationFlags.newFollowers = hasNew;
}
@end
