//
//  WeiboAccount.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAccount.h"
#import "WeiboAccount+Filters.h"
#import "WeiboAccount+Superpower.h"
#import "WeiboAccount+DirectMessage.h"
#import "WeiboAPI+UnreadCount.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboAPI+DirectMessages.h"
#import "WeiboUser.h"
#import "WeiboUnread.h"
#import "WeiboRequestError.h"
#import "WeiboStream.h"
#import "WeiboTimelineStream.h"
#import "WeiboMentionsStream.h"
#import "WeiboCommentMentionsStream.h"
#import "WeiboCommentsToMeStream.h"
#import "WeiboCommentsByMeStream.h"
#import "WeiboFavoritesStream.h"
#import "WeiboUserTimelineStream.h"
#import "WeiboRepliesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboComment.h"
#import "WeiboDirectMessagesConversationManager.h"
#import "WeiboUserNotificationCenter.h"

#import "NSArray+WeiboAdditions.h"
#import "WTCallback.h"
#import "WTFoundationUtilities.h"
#import "SSKeychain.h"
#import "JSONKit.h"
#import "WTHTTPRequest.h"
#import "WTFileManager.h"

#define CACHE_LIVETIME 600.0

NSString * const WeiboStatusFavoriteStateDidChangeNotifiaction = @"WeiboStatusFavoriteStateDidChangeNotifiaction";

@interface WeiboAccount ()

@property (nonatomic, retain) WeiboDirectMessagesConversationManager * directMessagesManager;

@end

@implementation WeiboAccount
@synthesize username, password, oAuthToken, oAuthTokenSecret, user, apiRoot;
@synthesize delegate = _delegate, notificationOptions;
@synthesize oAuth2Token = _oAuth2Token, expireTime = _expireTime;
@synthesize tokenExpired = _tokenExpired, profileImage = _profileImage;
@synthesize newDirectMessagesCount = _newDirectMessagesCount;

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
    [commentMentionsStream release];
    [commentsToMeStream release];
    [commentsByMeStream release];
    [favoritesStream release];
    [_profileImage release];
    [_lists release], _lists = nil;
    
    [_keywordFilters release], _keywordFilters = nil;
    [_userFilters release], _userFilters = nil;
    [_clientFilters release], _clientFilters = nil;
    [_userHighlighters release], _userHighlighters = nil;
    
    [_mentionHighlighter release], _mentionHighlighter = nil;
    [_advertisementFilter release], _advertisementFilter = nil;
    
    [_superpowerToken release], _superpowerToken = nil;
    [_directMessagesManager release], _directMessagesManager = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        notificationOptions = WeiboNotificationDefaults;
        
        timelineStream = [[WeiboTimelineStream alloc] init];
        timelineStream.account = self;
        
        mentionsStream = [[WeiboMentionsStream alloc] init];
        mentionsStream.account = self;
        
        commentMentionsStream = [[WeiboCommentMentionsStream alloc] init];
        commentMentionsStream.account = self;
        
        commentsToMeStream = [[WeiboCommentsToMeStream alloc] init];
        commentsToMeStream.account = self;
        
        commentsByMeStream = [[WeiboCommentsByMeStream alloc] init];
        commentsByMeStream.account = self;
        
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
    [encoder encodeInt64:notificationOptions forKey:@"notification-options"];
    [encoder encodeObject:user forKey:@"user"];
    
    [encoder encodeObject:self.keywordFilters forKey:@"keyword-filters"];
    [encoder encodeObject:self.userFilters forKey:@"user-filters"];
    [encoder encodeObject:self.userHighlighters forKey:@"user-highlighters"];
    [encoder encodeObject:self.clientFilters forKey:@"client-filters"];
    [encoder encodeObject:@(self.filterAdvertisements) forKey:@"filter-advertisements"];
    
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.keywordFilters] forKey:@"keyword-filters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.userFilters] forKey:@"user-filters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.userHighlighters] forKey:@"user-highlighters"];
//    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.clientFilters] forKey:@"client-filters"];
    
    [encoder encodeObject:self.profileImage forKey:@"profile-image"];
    
    [encoder encodeBool:self.superpowerTokenExpired forKey:@"superpower-token-expired"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        username = [[decoder decodeObjectForKey:@"username"] retain];
        apiRoot = [[decoder decodeObjectForKey:@"api-root"] retain];
        notificationOptions = [decoder decodeInt64ForKey:@"notification-options"];
        notificationOptions = [self versionNotificationOptions:notificationOptions];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.profileImage = [decoder decodeObjectForKey:@"profile-image"];
        self.superpowerTokenExpired = [decoder decodeBoolForKey:@"superpower-token-expired"];
        
        id filterAdvertisements = [decoder decodeObjectForKey:@"filter-advertisements"];
        if (filterAdvertisements)
        {
            self.filterAdvertisements = [filterAdvertisements boolValue];
        }
        else
        {
            self.filterAdvertisements = YES; // default is YES
        }
        
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
            
            [self restoreSuperpowerTokenFromKeychain];
        }
        
        
        if (self.oAuth2Token)
        {
            [self verifyCredentials:nil];
        }
    }
    return self;
}

- (void)willSaveToDisk
{
    [self saveDirectMessages];
}
- (void)didRestoreFromDisk
{
    _directMessagesManager = [[self restoreDirectMessageManager] retain];
    
    [self refreshDirectMessages];
}
- (void)refreshDirectMessages
{
    if (self.directMessagesManager)
    {
        if (!self.directMessagesManager.receivedStream.isLoading)
        {
            [self resetUnreadCountWithType:WeiboUnreadCountTypeDirectMessage];
        }
        
        [self.directMessagesManager refresh];
    }
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
        self.filterAdvertisements = YES;
        
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
- (WeiboCommentMentionsStream *)commentMentionsStream
{
    return commentMentionsStream;
}
- (WeiboCommentsToMeStream *)commentsToMeStream
{
    return commentsToMeStream;
}
- (WeiboCommentsByMeStream *)commentsByMeStream
{
    return commentsByMeStream;
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
- (WeiboNotificationOptions)versionNotificationOptions:(WeiboNotificationOptions)options
{
    if (!(options & WeiboNotificationVersionSystemCenterIntegrated))
    {
        NSMutableArray * bits = [NSMutableArray array];
        
        NSInteger userBitsCount = 24;
        
        for (int i = 0; i < userBitsCount; i++)
        {
            [bits addObject:@((options & (1 << i)) ? 1 : 0)];
        }
        
        [bits insertObject:@0 atIndex:2];
        [bits insertObject:@1 atIndex:5];
        [bits insertObject:@1 atIndex:8];
        [bits insertObject:@1 atIndex:11];
        [bits insertObject:@1 atIndex:14];
        
        options = 0;
        
        for (int i = 0; i < userBitsCount; i++)
        {
            options |= [bits[i] longLongValue] << i;
        }
        
        options |= WeiboNotificationVersionSystemCenterIntegrated;
    }
    return options;
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

- (WeiboDirectMessagesConversationManager *)directMessagesManager
{
    if (!self.superpowerAuthorized) return nil;
    
    if (!_directMessagesManager)
    {
        _directMessagesManager = [[WeiboDirectMessagesConversationManager alloc] initWithAccount:self];
    }
    
    return _directMessagesManager;
}

#pragma mark -
#pragma mark Timeline
- (void)forceRefreshTimelines
{
    [timelineStream loadNewer];
    [mentionsStream loadNewer];
    [commentMentionsStream loadNewer];
    [commentsToMeStream loadNewer];
}
- (void)refreshTimelineForType:(WeiboCompositionType)type{
    switch (type) {
        case WeiboCompositionTypeNewTweet:
            [timelineStream loadNewer];
            break;
        case WeiboCompositionTypeComment:
            //[commentsTimelineStream loadNewer];
            break;
        case WeiboCompositionTypeDirectMessage:
            [self.directMessagesManager refresh];
        default:
            break;
    }
}
- (void)refreshMentions
{
    [mentionsStream loadNewer];
    [commentMentionsStream loadNewer];
}
- (void)refreshComments
{
    [commentsToMeStream loadNewer];
    [commentsByMeStream loadNewer];
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
    
    self.newStatusesCount = unread.newStatus;
    self.newStatusMentionsCount = unread.newStatusMentions;
    self.newCommentMentionsCount = unread.newCommentMentions;
    self.newCommentsCount = unread.newComments;
    self.newDirectMessagesCount = unread.newDirectMessages;
    
    if (unread.newFollowers > self.newFollowersCount)
    {
        [[WeiboUserNotificationCenter defaultUserNotificationCenter] scheduleNotificationForNewFollowersCount:unread.newFollowers forAccount:self];
    }
    self.newFollowersCount = unread.newFollowers;
    
    
    if (unread.newStatus > 0)
    {
        [timelineStream loadNewer];
    }
    if (unread.newStatusMentions > 0)
    {
        [mentionsStream loadNewer];
        [self resetUnreadCountWithType:WeiboUnreadCountTypeStatusMention];
    }
    if (unread.newCommentMentions)
    {
        [commentMentionsStream loadNewer];
        [self resetUnreadCountWithType:WeiboUnreadCountTypeCommentMention];
    }
    if (unread.newComments > 0)
    {
        [commentsToMeStream loadNewer];
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
    
    switch (type)
    {
        case WeiboUnreadCountTypeDirectMessage:[self setNewDirectMessagesCount:0];break;
        case WeiboUnreadCountTypeFollower:[self setNewFollowersCount:0];break;
        case WeiboUnreadCountTypeStatusMention:[self setNewStatusMentionsCount:0];break;
        case WeiboUnreadCountTypeCommentMention:[self setNewCommentMentionsCount:0];break;
        case WeiboUnreadCountTypeComment:[self setNewCommentsCount:0];break;
        default:break;
    }
}

#pragma mark -
#pragma mark Composition
- (void)sendCompletedComposition:(id<WeiboComposition>)composition
{
    WTCallback * callback = WTCallbackMake(self, @selector(didSendCompletedComposition:info:), composition);
    
    if (composition.type == WeiboCompositionTypeDirectMessage)
    {
        [self.directMessagesManager requestStreaming];
        
        WeiboAPI * api = [self authenticatedSuperpowerRequest:callback];
        [api sendDirectMessage:composition.text toUserID:composition.directMessageUser.userID];
        
        double delayInSeconds = 90.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){            
            [self.directMessagesManager endStreaming];
        });
    }
    else
    {
        WeiboAPI * api = [self authenticatedRequest:callback];
        [api updateWithComposition:composition];
    }
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

- (void)postStatusFavoriteStateChangedNotification:(WeiboStatus *)status
{
    NSDictionary * userInfo = @{@"status" : status};
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboStatusFavoriteStateDidChangeNotifiaction object:self userInfo:userInfo];
}

- (void)toggleFavoriteOfStatus:(WeiboStatus *)status
{
    BOOL shouldUnfavorite = status.favorited;
    
    NSDictionary * userInfo = @{@"status":status, @"favorite-state": @(status.favorited)};
    
    status.favorited = !status.favorited;
    
    [self postStatusFavoriteStateChangedNotification:status];
    
    WTCallback * callback = WTCallbackMake(self, @selector(favoriteActionResponse:info:), userInfo);
    
    WeiboAPI * api = [self authenticatedRequest:callback];
    
    if (shouldUnfavorite)
    {
        [api unfavoriteStatusID:status.sid];
    }
    else
    {
        [api favoriteStatusID:status.sid];
    }
}
- (void)favoriteActionResponse:(id)response info:(id)info
{
    WeiboStatus * status = info[@"status"];
    BOOL favoriteState = [info[@"favorite-state"] boolValue];
    
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        NSInteger code = [(WeiboRequestError *)response code];
        
        if (code == WeiboErrorCodeNotFavorited)
        {
            status.favorited = NO;
        }
        else if (code == WeiboErrorCodeAlreadyFavorited)
        {
            status.favorited = YES;
        }
        else
        {
            status.favorited = favoriteState;
        }
    }
    else if ([response isKindOfClass:[NSString class]])
    {
        NSDictionary * dict = [(NSString *)response objectFromJSONString];
        NSDictionary * statusDict = [dict objectForKey:@"status"];
        
        WeiboStatus * newStatus = [WeiboStatus statusWithDictionary:statusDict];
        
        status.favorited = newStatus.favorited;
    }
    
    [self postStatusFavoriteStateChangedNotification:status];
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
}
- (BOOL)hasFreshComments
{
    WeiboBaseStatus * topStatus = [commentsToMeStream newestStatus];
    if (!topStatus)
    {
        return NO;
    }
    return topStatus.sid > commentsToMeStream.viewedMostRecentID;
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
- (NSInteger)unreadCountForDockBadge
{
    NSInteger count = 0;
    
    if (notificationOptions & WeiboTweetNotificationBadge)
    {
        count += self.newStatusesCount;
    }
    
    if (notificationOptions & WeiboMentionNotificationBadge)
    {
        count += self.newMentionsCount;
    }
    
    if (notificationOptions & WeiboCommentNotificationBadge)
    {
        count += self.newCommentsCount;
    }
    
    if (notificationOptions & WeiboDirectMessageNotificationBadge)
    {
        count += self.newDirectMessagesCount;
    }
    
    if (notificationOptions & WeiboFollowerNotificationBadge)
    {
        count += self.newFollowersCount;
    }
    
    return count;
}

- (NSInteger)newDirectMessagesCount
{
    if (self.directMessagesManager)
    {
        return self.directMessagesManager.unreadConversations.count;
    }
    
    return _newDirectMessagesCount;
}

- (NSInteger)newStatusesCount
{
    if (self.timelineStream.statuses.count)
    {
        return self.timelineStream.unreadCount;
    }
    return _newStatusesCount;
}

- (NSInteger)newMentionsCount
{
    return self.newStatusMentionsCount + self.newCommentMentionsCount;
}
- (NSInteger)newStatusMentionsCount
{
    if (self.mentionsStream.hasData)
    {
        return self.mentionsStream.unreadCount;
    }
    return _newStatusMentionsCount;
}
- (NSInteger)newCommentMentionsCount
{
    if (self.commentMentionsStream.hasData)
    {
        return self.commentMentionsStream.unreadCount;
    }
    return _newCommentMentionsCount;
}

- (NSInteger)newCommentsCount
{
    if (self.commentsToMeStream.hasData)
    {
        return self.commentsToMeStream.unreadCount;
    }
    return _newCommentsCount;
}

- (void)setNewDirectMessagesCount:(NSInteger)newDirectMessagesCount
{
    _newDirectMessagesCount = newDirectMessagesCount;
    
    if (newDirectMessagesCount && self.directMessagesManager)
    {
        [self refreshDirectMessages];
    }
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
