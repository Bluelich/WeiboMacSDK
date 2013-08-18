//
//  WeiboAccount.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"
#import "WeiboAccount+Filters.h"
#import "WeiboAPI+UnreadCount.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboUser.h"
#import "WeiboUnread.h"
#import "WeiboRequestError.h"
#import "WeiboStream.h"
#import "WeiboTimelineStream.h"
#import "WeiboMentionsStream.h"
#import "WeiboCommentsTimelineStream.h"
#import "WeiboFavoritesStream.h"
#import "WeiboUserTimelineStream.h"
#import "WeiboRepliesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboComment.h"
#import "NSArray+WeiboAdditions.h"
#import "WTCallback.h"
#import "WTFoundationUtilities.h"
#import "SSKeychain.h"
#import "WTHTTPRequest.h"

#define CACHE_LIVETIME 600.0

@implementation WeiboAccount
@synthesize username, password, oAuthToken, oAuthTokenSecret, user, apiRoot;
@synthesize delegate = _delegate, notificationOptions;
@synthesize oAuth2Token = _oAuth2Token, expireTime = _expireTime;
@synthesize tokenExpired = _tokenExpired, profileImage = _profileImage;

#pragma mark -
#pragma mark Life Cycle
- (void)dealloc
{
    [username release]; 
    [password release];
    [apiRoot release];
    [oAuthToken release];
    [oAuthTokenSecret release];
    [_oAuth2Token release];
    [user release];
    [usersByUsername release];
    [timelineStream release];
    [mentionsStream release];
    [commentsTimelineStream release];
    [favoritesStream release];
    [_profileImage release];
    [_lists release], _lists = nil;
    
    [_keywordFilters release], _keywordFilters = nil;
    [_userFilters release], _userFilters = nil;
    [_clientFilters release], _clientFilters = nil;
    [_userHighlighters release], _userHighlighters = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        notificationOptions = WeiboTweetNotificationMenubar | WeiboMentionNotificationMenubar |
                              WeiboFollowerNotificationMenubar | WeiboCommentNotificationMenubar | 
                              WeiboDirectMessageNotificationMenubar;
        timelineStream = [[WeiboTimelineStream alloc] init];
        timelineStream.account = self;
        mentionsStream = [[WeiboMentionsStream alloc] init];
        mentionsStream.account = self;
        commentsTimelineStream = [[WeiboCommentsTimelineStream alloc] init];
        commentsTimelineStream.account = self;
        favoritesStream = [[WeiboFavoritesStream alloc] init];
        favoritesStream.account = self;

        usersByUsername = [[NSMutableDictionary alloc] init];
        outbox = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:oAuthToken forKey:@"oauth-token"];
    [encoder encodeObject:apiRoot forKey:@"api-root"];
    [encoder encodeInteger:notificationOptions forKey:@"notification-options"];
    [encoder encodeObject:user forKey:@"user"];
    
    [encoder encodeObject:self.keywordFilters forKey:@"keyword-filters"];
    [encoder encodeObject:self.userFilters forKey:@"user-filters"];
    [encoder encodeObject:self.userHighlighters forKey:@"user-highlighters"];
    [encoder encodeObject:self.clientFilters forKey:@"client-filters"];
    
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.keywordFilters] forKey:@"keyword-filters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.userFilters] forKey:@"user-filters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.userHighlighters] forKey:@"user-highlighters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.clientFilters] forKey:@"client-filters"];
    
    [encoder encodeObject:self.profileImage forKey:@"profile-image"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        username = [[decoder decodeObjectForKey:@"username"] retain];
        apiRoot = [[decoder decodeObjectForKey:@"api-root"] retain];
        notificationOptions = [decoder decodeIntegerForKey:@"notification-options"];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.profileImage = [decoder decodeObjectForKey:@"profile-image"];
        
        [self setFilterArray:[decoder decodeObjectForKey:@"keyword-filters"] forKeyPath:@"keywordFilters"];
        [self setFilterArray:[decoder decodeObjectForKey:@"user-filters"] forKeyPath:@"userFilters"];
        [self setFilterArray:[decoder decodeObjectForKey:@"user-highlighters"] forKeyPath:@"userHighlighters"];
        [self setFilterArray:[decoder decodeObjectForKey:@"client-filters"] forKeyPath:@"clientFilters"];
        
        WeiboUserID userID = self.user.userID;
        
        if (userID)
        {
            NSString * keyChainAccount = [[self class] keyChainAccountForUserID:userID];
            
            self.oAuth2Token = [SSKeychain passwordForService:[self keychainService]
                                                      account:keyChainAccount];
        }
        
        if (self.oAuth2Token)
        {
            [self verifyCredentials:nil];
        }
    }
    return self;
}
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword apiRoot:(NSString *)root
{
    if ((self = [self init])) {
        username = [aUsername retain];
        password = [aPassword retain];
        apiRoot  = [root retain];
    }
    return self;
}
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    return [self initWithUsername:aUsername password:aPassword apiRoot:WEIBO_APIROOT_DEFAULT];
}
- (id)initWithUserID:(WeiboUserID)userID oAuth2Token:(NSString *)token
{
    if (self = [self init])
    {
        WeiboUser * dummyUser = [[WeiboUser new] autorelease];
        dummyUser.userID = userID;
        
        self.user = dummyUser;
        self.oAuth2Token = token;
        
        apiRoot = [WEIBO_APIROOT_DEFAULT retain];
    }
    return self;
}


#pragma mark -
#pragma mark Accessor

+ (NSString *)keyChainAccountForUserID:(WeiboUserID)userID
{
    return [NSString stringWithFormat:@"AccessToken:%lld",userID];
}

- (WeiboTimelineStream *) timelineStream{
    return timelineStream;
}
- (WeiboMentionsStream *) mentionsStream{
    return mentionsStream;
}
- (WeiboCommentsTimelineStream *) commentsTimelineStream{
    return commentsTimelineStream;
}
- (WeiboFavoritesStream *) favoritesStream{
    return favoritesStream;
}
- (void)setUser:(WeiboUser *)newUser{
    [newUser retain];
    [user release];
    user = newUser;
    [self requestProfileImageWithCallback:nil];
}

#pragma mark -
#pragma mark Core Methods
- (NSString *)keychainService{
    NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return identifier;
}                                                            
- (BOOL)isEqualToAccount:(WeiboAccount *)anotherAccount
{
    if (self.username)
    {
        return [self.username isEqualToString:anotherAccount.username];
    }
    else if (self.user.userID)
    {
        return [self.user isEqual:anotherAccount.user];
    }
    return NO;
}
- (BOOL)isEqual:(id)object
{
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

- (NSMutableArray *)keywordFilters
{
    if (!_keywordFilters)
    {
        _keywordFilters = [[NSMutableArray alloc] init];
    }
    return _keywordFilters;
}
- (NSMutableArray *)userFilters
{
    if (!_userFilters)
    {
        _userFilters = [[NSMutableArray alloc] init];
    }
    return _userFilters;
}
- (NSMutableArray *)userHighlighters
{
    if (!_userHighlighters)
    {
        _userHighlighters = [[NSMutableArray alloc] init];
    }
    return _userHighlighters;
}
- (NSMutableArray *)clientFilters
{
    if (!_clientFilters)
    {
        _clientFilters = [[NSMutableArray alloc] init];
    }
    return _clientFilters;
}
//- (void)setFilterArray:(NSData *)filtersData forKeyPath:(NSString *)keyPath
- (void)setFilterArray:(NSMutableArray *)filters forKeyPath:(NSString *)keyPath
{
    NSMutableArray * result = nil;
//    id filters = [NSKeyedUnarchiver unarchiveObjectWithData:filtersData];
    
    if ([filters isKindOfClass:[NSMutableArray class]])
    {
        result = filters;
    }
    else if ([filters isKindOfClass:[NSArray class]])
    {
        result = [[filters mutableCopy] autorelease];
    }
    else if (filters)
    {
        NSLog(@"wrong!!");
    }
    
    [self setValue:result forKeyPath:keyPath];
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
        case WeiboCompositionTypeNewTweet:
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
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        return ;
    }
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
    [self setNewDirectMessagesCount:unread.newDirectMessages];
    // can NOT get access to DM api yet, just post a notification

    [self setNewFollowersCount:unread.newFollowers];
    
    if ([_delegate respondsToSelector:@selector(account:finishCheckingUnreadCount:)]) {
        [_delegate account:self finishCheckingUnreadCount:unread];
    }
}
- (void)resetUnreadCountWithType:(WeiboUnreadCountType)type
{
    WTCallback * callback = WTCallbackMake(self, @selector(unreadCountResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api resetUnreadWithType:type];
    
    switch (type) {
        case WeiboUnreadCountTypeDirectMessage:[self setNewDirectMessagesCount:0];break;
        case WeiboUnreadCountTypeFollower:[self setNewFollowersCount:0];break;
        case WeiboUnreadCountTypeMention:[self setNewMentionsCount:0];break;
        case WeiboUnreadCountTypeComment:[self setNewCommentsCount:0];break;
        default:break;
    }
}

#pragma mark -
#pragma mark Composition
- (void)sendCompletedComposition:(id<WeiboComposition>)composition
{
    WTCallback * callback = WTCallbackMake(self, @selector(didSendCompletedComposition:info:), composition);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api updateWithComposition:composition];
}
- (void)didSendCompletedComposition:(id)response info:(id)info
{
    id<WeiboComposition> composition = info;
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        WeiboRequestError * error = response;
        [composition errorSending];
        [_delegate account:self didFailToPost:composition errorMessage:error.errorString error:error];
    }
    [composition didSend:response];
}

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
    [self cacheUser:newUser];
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

+ (NSImage*)scaleImage:(NSImage*)image toSize:(NSSize)size
{
	NSSize originalSize = [image size];
	NSSize scaledSize = size;
	
	if(originalSize.width > originalSize.height)
		scaledSize.height = (size.height * originalSize.height) / originalSize.width;
	else
		scaledSize.width = (size.width * originalSize.width) / originalSize.height;
    
	NSImage* icon = [[NSImage alloc] initWithSize:size];
    
	[icon lockFocus];
    
    float xoff = (size.width - scaledSize.width) * 0.50;
    float yoff = (size.height - scaledSize.height) * 0.50;
    
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawInRect:NSMakeRect(xoff, yoff, scaledSize.width, scaledSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[icon unlockFocus];
	
	return [icon autorelease];
}

- (NSImage *)profileImage
{
    if (!_profileImage && !_flags.requestingAvatar)
    {
        [self requestProfileImageWithCallback:nil];
    }
    return _profileImage;
}

- (void)profileImageResponse:(id)response info:(id)info
{
    _flags.requestingAvatar = 0;
    
    WTCallback * callback = (WTCallback *)info;
    
    NSImage * image = [[[NSImage alloc] initWithData:response] autorelease];
    if (image) {
        if (image.size.width > 50 || image.size.height > 50)
        {
            image = [[self class] scaleImage:image toSize:NSMakeSize(50, 50)];
        }
        self.profileImage = image;
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kWeiboAccountAvatarDidUpdateNotification object:image];
    }
    [callback invoke:image];
}
- (void)requestProfileImageWithCallback:(WTCallback *)aCallback
{
    _flags.requestingAvatar = 1;
    
    WTCallback * callback = WTCallbackMake(self, @selector(profileImageResponse:info:), aCallback);
    NSURL * url = [NSURL URLWithString:self.user.profileLargeImageUrl];
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        [callback invoke:request.responseData];
    }];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark User Detail Streams
- (NSMutableDictionary *)_userDetailsStreamCache{
    if (!userDetailsStreamsCache) {
        userDetailsStreamsCache = [[NSMutableDictionary alloc] init];
    }
    return userDetailsStreamsCache;
}
- (id)_cachedStream:(NSString *)key{
    return [[self _userDetailsStreamCache] objectForKey:key];
}
- (WeiboUserTimelineStream *)timelineStreamForUser:(WeiboUser *)aUser{
    if (!user) return nil;
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

#pragma mark - Cache
- (void)pruneStatusCache
{
    {
        NSMutableArray * keysToRemove = [NSMutableArray arrayWithCapacity:userDetailsStreamsCache.count];
        for (NSString * key in userDetailsStreamsCache) {
            WeiboStream * stream = [userDetailsStreamsCache objectForKey:key];
            if ([NSDate timeIntervalSinceReferenceDate] - stream.cacheTime > CACHE_LIVETIME) {
                [keysToRemove addObject:key];
            }
        }
        [userDetailsStreamsCache removeObjectsForKeys:keysToRemove];
    }
}
- (void)pruneUserCache
{
    {
        NSMutableArray * keysToRemove = [NSMutableArray array];
        for (NSString * screenname in usersByUsername) {
            WeiboUser * theUser = [usersByUsername objectForKey:screenname];
            if ([NSDate timeIntervalSinceReferenceDate] - theUser.cacheTime > CACHE_LIVETIME) {
                [keysToRemove addObject:screenname];
            }
        }
        [usersByUsername removeObjectsForKeys:keysToRemove];
    }
}

- (void)cacheUser:(WeiboUser *)newUser{
    if ([newUser isKindOfClass:[WeiboUser class]]) {
        [usersByUsername setObject:newUser forKey:newUser.screenName];
        [newUser setCacheTime:[NSDate timeIntervalSinceReferenceDate]];
    }
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
    return topStatus.sid > timelineStream.viewedMostRecentID;
    //return !topStatus.wasSeen;
}
- (BOOL)hasFreshMentions{
    WeiboBaseStatus * topStatus = [mentionsStream newestStatus];
    if (!topStatus) {
        return NO;
    }
    return topStatus.sid > mentionsStream.viewedMostRecentID;
    //return !topStatus.wasSeen;
}
- (BOOL)hasFreshComments{
    WeiboBaseStatus * topStatus = [commentsTimelineStream newestStatus];
    if (!topStatus) {
        return NO;
    }
    return topStatus.sid > commentsTimelineStream.viewedMostRecentID;
    //return !topStatus.wasSeen;
}
- (BOOL)hasFreshDirectMessages
{
    return self.newDirectMessagesCount > 0;
}
- (BOOL)hasNewFollowers
{
    return self.newFollowersCount > 0;
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

@end
