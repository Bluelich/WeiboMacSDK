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
#import "WeiboRepostsStream.h"
#import "WeiboLikesStream.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboComment.h"
#import "WeiboDirectMessagesConversationManager.h"
#import "WeiboUserNotificationCenter.h"
#import "Weibo.h"
#import "WeiboCryptographer.h"
#import "WeiboStatusAdvertisementFilter.h"
#import "WeiboStatusAccountMentionFilter.h"

#import "NSArray+WeiboAdditions.h"
#import "WeiboCallback.h"
#import "WeiboFoundationUtilities.h"
#import "SSKeychain.h"
#import "JSONKit.h"
#import "WeiboHTTPRequest.h"
#import "WeiboFileManager.h"

#define CACHE_LIVETIME 600.0

NSString * const WeiboStatusFavoriteStateDidChangeNotifiaction = @"WeiboStatusFavoriteStateDidChangeNotifiaction";
NSString * const WeiboAccountSavedSearchesDidChangeNotification = @"WeiboAccountSavedSearchesDidChangeNotification";
NSString * const WeiboUserRemarkDidUpdateNotification = @"WeiboUserRemarkDidUpdateNotification";


@interface WeiboAccount ()

@property (nonatomic, strong) WeiboDirectMessagesConversationManager * directMessagesManager;
@property (nonatomic, strong) NSMutableArray * savedSearchKeywords;

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
    _lists = nil;
    
    _keywordFilters = nil;
    _userFilters = nil;
    _clientFilters = nil;
    _userHighlighters = nil;
    
    _mentionHighlighter = nil;
    _advertisementFilter = nil;
    
    _superpowerToken = nil;
    _directMessagesManager = nil;
    
    _savedSearchKeywords = nil;
    
}

- (id)init
{
    if (self = [super init])
    {
        notificationOptions = WeiboNotificationDefaults;
        
        timelineStream = [[WeiboTimelineStream alloc] init];
        timelineStream.account = self;
        
        statusMentionsStream = [[WeiboMentionsStream alloc] init];
        statusMentionsStream.account = self;
        
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
    
    [encoder encodeObject:self.savedSearchKeywords forKey:@"saved-searches"];
    [encoder encodeObject:_lists forKey:@"lists"];
    
    NSString * token = [[WeiboCryptographer sharedCryptographer] encryptText:self.oAuth2Token salt:[@(user.userID) stringValue]];
    [encoder encodeObject:token forKey:@"token"];
    
    NSString * superpowerToken = [[WeiboCryptographer sharedCryptographer] encryptText:self.superpowerToken salt:[@(user.userID) stringValue]];
    [encoder encodeObject:superpowerToken forKey:@"superpower-token"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        username = [decoder decodeObjectForKey:@"username"];
        apiRoot = [decoder decodeObjectForKey:@"api-root"];
        notificationOptions = [decoder decodeInt64ForKey:@"notification-options"];
        notificationOptions = [self versionNotificationOptions:notificationOptions];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.profileImage = [decoder decodeObjectForKey:@"profile-image"];
        self.superpowerTokenExpired = [decoder decodeBoolForKey:@"superpower-token-expired"];
        
        self.savedSearchKeywords = [[decoder decodeObjectForKey:@"saved-searches"] mutableCopy];
        
        _lists = [[decoder decodeObjectForKey:@"lists"] mutableCopy];
        
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
            NSString * token = [decoder decodeObjectForKey:@"token"];
            
            NSLog(@"<Token> decoder中存储的token为: %@", token);
            
            token = [[WeiboCryptographer sharedCryptographer] decryptText:token salt:[@(userID) stringValue]];
            
            NSLog(@"<Token> 解密后的token为: %@", token.stringForLogging);
            
            self.oAuth2Token = token;
            
            if (!self.oAuth2Token.length)
            {
                NSLog(@"<Token> 将从keyChain恢复token");
                
                // old versions migration
                NSString * keyChainAccount = [[self class] keyChainAccountForUserID:userID];
                
                self.oAuth2Token = [SSKeychain passwordForService:[self keychainService]
                                                          account:keyChainAccount];
                
                NSLog(@"<Token> keychain恢复的token为:%@", self.oAuth2Token.stringForLogging);
            }
            if (!self.oAuth2Token.length)
            {
                self.oAuth2Token = @"can_not_restore_token"; // fake value, we should treat this situation like token is expired.
                NSLog(@"<Token> 已使用过期token:%@", self.oAuth2Token);
            }
            
            NSString * superpowerToken = [decoder decodeObjectForKey:@"superpower-token"];;
            NSLog(@"<Token> decoder中存储的superpower-token为: %@", superpowerToken);
            
            superpowerToken = [[WeiboCryptographer sharedCryptographer] decryptText:superpowerToken salt:[@(userID) stringValue]];
            
            NSLog(@"<Token> 解密后的superpower-token为: %@", superpowerToken.stringForLogging);
            
            self.superpowerToken = superpowerToken;
            
            if (!self.superpowerToken)
            {
                NSLog(@"<Token> 将尝试从keychain恢复superpower-token");
                
                [self restoreSuperpowerTokenFromKeychain];
                
                NSLog(@"<Token> 恢复后的superpower-token为: %@", superpowerToken.stringForLogging);
            }
        }
        
        
        if (self.oAuth2Token)
        {
            [self verifyCredentials:nil];
        }
    }
    return self;
}

- (void)updateWithAccount:(WeiboAccount *)account
{
    if (![self.user isEqual:account.user]) return;
    
    self.oAuth2Token = account.oAuth2Token;
    self.user = account.user;
    self.oAuthToken = account.oAuthToken;
    self.oAuthTokenSecret = account.oAuthTokenSecret;
    self.tokenExpired = account.tokenExpired;
    self.expireTime = account.expireTime;
}

- (void)willSaveToDisk
{
    [self saveDirectMessages];
}
- (void)didRestoreFromDisk
{
    _directMessagesManager = [self restoreDirectMessageManager];
    
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
        username = aUsername;
        password = aPassword;
        apiRoot  = root;
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
        WeiboUser * dummyUser = [WeiboUser new];
        dummyUser.userID = userID;
        
        self.user = dummyUser;
        self.oAuth2Token = token;
        self.filterAdvertisements = YES;
        
        apiRoot = WEIBO_APIROOT_DEFAULT;
    }
    return self;
}


#pragma mark -
#pragma mark Accessor

+ (NSString *)keyChainAccountForUserID:(WeiboUserID)userID
{
    return [NSString stringWithFormat:@"AccessToken:%lld",userID];
}

- (WeiboTimelineStream *)timelineStream
{
    return timelineStream;
}
- (WeiboMentionsStream *)statusMentionsStream
{
    return statusMentionsStream;
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
    user = newUser;
    [self requestProfileImageWithCallback:nil];
}
- (WeiboNotificationOptions)versionNotificationOptions:(WeiboNotificationOptions)options
{
    if (!(options & WeiboNotificationVersionSystemCenterIntegrated))
    {
        NSMutableArray * bits = [NSMutableArray array];
        
        NSUInteger userBitsCount = 24;
        
        for (NSUInteger i = 0; i < userBitsCount; i++)
        {
            [bits addObject:@((options & (1 << i)) ? 1 : 0)];
        }
        
        [bits insertObject:@0 atIndex:2];
        [bits insertObject:@1 atIndex:5];
        [bits insertObject:@1 atIndex:8];
        [bits insertObject:@1 atIndex:11];
        [bits insertObject:@1 atIndex:14];
        
        options = 0;
        
        for (NSUInteger i = 0; i < userBitsCount; i++)
        {
            options |= [bits[i] longLongValue] << i;
        }
        
        options |= WeiboNotificationVersionSystemCenterIntegrated;
    }
    return options;
}

#pragma mark -
#pragma mark Core Methods
- (NSString *)keychainService
{
    return [Weibo globalKeychainService];
}
- (NSUInteger)hash
{
    if (self.username) {
        return self.username.hash;
    }
    return self.user.userID;
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
- (WeiboAPI *)request:(WeiboCallback *)callback{
    return [WeiboAPI requestWithAPIRoot:self.apiRoot callback:callback];
}
- (WeiboAPI *)authenticatedRequest:(WeiboCallback *)callback{
    return [WeiboAPI authenticatedRequestWithAPIRoot:self.apiRoot account:self callback:callback];
}
- (WeiboAPI *)authenticatedRequestWithCompletion:(WeiboCallbackBlock)completion
{
    return [WeiboAPI authenticatedRequestWithAPIRoot:self.apiRoot account:self completion:completion];
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
        result = [filters mutableCopy];
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
    [statusMentionsStream loadNewer];
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
    [statusMentionsStream loadNewer];
    [commentMentionsStream loadNewer];
}
- (void)refreshComments
{
    [commentsToMeStream loadNewer];
    [commentsByMeStream loadNewer];
}
- (void)refreshTimelines{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(unreadCountResponse:info:), nil);
    WeiboAPI * api = [self authenticatedRequest:callback];
    [api unreadCountSinceID:[timelineStream newestStatusID]];
    if ([_delegate respondsToSelector:@selector(account:didCheckingUnreadCount:)]) {
        [_delegate account:self didCheckingUnreadCount:nil];
    }
}
- (void)unreadCountResponse:(id)response info:(id __attribute__((unused)))info{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        return ;
    }
    
    WeiboUnread * unread = (WeiboUnread *)response;
    
    self.newStatusesCount = (NSInteger)unread.newStatus;
    self.newStatusMentionsCount = (NSInteger)unread.newStatusMentions;
    self.newCommentMentionsCount = (NSInteger)unread.newCommentMentions;
    self.newCommentsCount = (NSInteger)unread.newComments;
    self.newDirectMessagesCount = (NSInteger)unread.newDirectMessages;
    
    if ((NSInteger)unread.newFollowers > self.newFollowersCount)
    {
        [[WeiboUserNotificationCenter defaultUserNotificationCenter] scheduleNotificationForNewFollowersCount:(NSInteger)unread.newFollowers forAccount:self];
    }
    self.newFollowersCount = (NSInteger)unread.newFollowers;
    
    
    if (unread.newStatus > 0)
    {
        [timelineStream loadNewer];
    }
    if (unread.newStatusMentions > 0)
    {
        [statusMentionsStream loadNewer];
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
    [self setNewDirectMessagesCount:(NSInteger)unread.newDirectMessages];
    // can NOT get access to DM api yet, just post a notification
    
    [self setNewFollowersCount:(NSInteger)unread.newFollowers];
    
    if ([_delegate respondsToSelector:@selector(account:finishCheckingUnreadCount:)]) {
        [_delegate account:self finishCheckingUnreadCount:unread];
    }
}
- (void)resetUnreadCountWithType:(WeiboUnreadCountType)type
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(unreadCountResponse:info:), nil);
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
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(didSendCompletedComposition:info:), composition);
    
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
    else if (composition.type == WeiboCompositionTypeRetweet)
    {
        WeiboAPI * api = [self authenticatedRequest:callback];
        
        WeiboStatus * status = (WeiboStatus *)composition.retweetingStatus;
        
        BOOL shouldComment = [composition.replyToStatus isEqual:composition.retweetingStatus];
        
        [api repost:composition.text repostingID:status.sid shouldComment:shouldComment];
    }
    else if (composition.type == WeiboCompositionTypeComment)
    {
        WeiboAPI * api = [self authenticatedRequest:callback];
        WeiboStatus * replyToStatus = (WeiboStatus *)composition.replyToStatus;
        WeiboComment * replyToComment = nil;
        
        if ([composition.replyToStatus isComment])
        {
            WeiboComment * comment = (WeiboComment *)composition.replyToStatus;
            replyToComment = comment;
            replyToStatus = replyToComment.replyToStatus;
        }
        
        [api reply:composition.text toStatusID:replyToStatus.sid toCommentID:replyToComment.sid];
        
        if ([replyToStatus isEqual:composition.retweetingStatus])
        {
            // Also retweet
            
            WeiboAPI * replyAPI = [self authenticatedRequest:nil];
            
            NSString * text = composition.text;
            
            if ([composition.replyToStatus isComment])
            {
                text = [self appendQuotationToText:text withStatus:composition.replyToStatus];
            }
            
            if (replyToStatus.quotedBaseStatus)
            {
                text = [self appendQuotationToText:text withStatus:replyToStatus];
            }
            
            [replyAPI repost:text repostingID:replyToStatus.sid shouldComment:NO];
        }
    }
    else
    {
        WeiboAPI * api = [self authenticatedRequest:callback];
        [api updateWithComposition:composition];
    }
}

- (NSString *)appendQuotationToText:(NSString *)text withStatus:(WeiboBaseStatus *)status
{
    NSString * additionalText = [NSString stringWithFormat:@" //@%@:%@", status.user.screenName, status.text];
    
    NSUInteger textLength = WeiboCompositionTextLength(text);
    NSUInteger additionalTextLength = WeiboCompositionTextLength(additionalText);
    
    if (textLength + additionalTextLength <= 140)
    {
        text = [text stringByAppendingString:additionalText];
    }
    
    return text;
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
- (void)userWithUsername:(NSString *)screenname callback:(WeiboCallback *)aCallback{
    WeiboUser * cachedUser = [usersByUsername objectForKey:screenname];
    if (cachedUser) {
        [self userResponse:cachedUser info:aCallback];
    }else {
        WeiboCallback * callback = WeiboCallbackMake(self, @selector(userResponse:info:), aCallback);
        WeiboAPI * api = [self authenticatedRequest:callback];
        [api userWithUsername:screenname];
    }
}
- (void)userResponse:(id)response info:(id)info{
    WeiboCallback * callback = (WeiboCallback *)info;
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
    [(WeiboCallback *)info invoke:self];
}
- (void)myUserDidUpdate:(WeiboUser * __attribute__((unused)))user{
    [self _postAccountDidUpdateNotification];
}
- (void)verifyCredentials:(WeiboCallback *)aCallback{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(myUserResponse:info:), aCallback);
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
    
    double xoff = (size.width - scaledSize.width) * 0.50;
    double yoff = (size.height - scaledSize.height) * 0.50;
    
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawInRect:NSMakeRect(xoff, yoff, scaledSize.width, scaledSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[icon unlockFocus];
	
	return icon;
}

- (NSImage *)profileImage
{
    if (!_profileImage && !_flags.requestingAvatar)
    {
        [self requestProfileImageWithCallback:nil];
    }
    return _profileImage;
}

- (void)requestProfileImageWithCallback:(WeiboCallback *)aCallback
{
    NSURL * url = [NSURL URLWithString:self.user.profileLargeImageUrl];
    
    if (!url) return;
    
    _flags.requestingAvatar = 1;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response __attribute__((unused)), NSData *data, NSError *connectionError __attribute__((unused))) {
        self->_flags.requestingAvatar = 0;
        if (data)
        {
            NSImage * image = [[NSImage alloc] initWithData:data];
            if (image)
            {
                if (image.size.width > 100 || image.size.height > 100)
                {
                    image = [[self class] scaleImage:image toSize:NSMakeSize(100, 100)];
                }
                image.size = NSMakeSize(50, 50);
                self.profileImage = image;
                NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:kWeiboAccountAvatarDidUpdateNotification object:image];
            }
        }
        // FIXME: callback data is enough?
        if (aCallback) [aCallback invoke:data];
    }];
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
    }
    return stream;
}

#pragma mark - Saved Searches

- (NSArray *)savedSearches
{
    return _savedSearchKeywords;
}
- (NSMutableArray *)savedSearchKeywords
{
    if (!_savedSearchKeywords)
    {
        _savedSearchKeywords = [[NSMutableArray alloc] init];
    }
    return _savedSearchKeywords;
}

- (NSString *)searchKeywordForSearchKey:(NSString *)searchKey
{
    if ([self isUserSearch:searchKey])
    {
        return [searchKey substringFromIndex:1];
    }
    else if ([self isTopicSearch:searchKey])
    {
        return [searchKey substringWithRange:NSMakeRange(1, searchKey.length - 2)];
    }
    return searchKey;
}

- (BOOL)isUserSearch:(NSString *)searchKey
{
    return [searchKey hasPrefix:@"@"];
}
- (BOOL)isTopicSearch:(NSString *)searchKey
{
    return [searchKey hasPrefix:@"#"] && [searchKey hasSuffix:@"#"];
}
- (BOOL)isKeywordSearch:(NSString *)searchKey
{
    return ![self isUserSearch:searchKey] && ![self isTopicSearch:searchKey];
}

- (NSString *)searchKeyForKeyword:(NSString *)keyword
{
    return keyword;
}
- (NSString *)searchKeyForUsername:(NSString *)aUsername
{
    return [NSString stringWithFormat:@"@%@", aUsername];
}
- (NSString *)searchKeyForTopicName:(NSString *)aTopicname
{
    return [NSString stringWithFormat:@"#%@#", aTopicname];
}

- (void)saveSearchWithKeyword:(NSString *)keyword
{
    [self saveSearchWithSearchKey:[self searchKeyForKeyword:keyword]];
}
- (void)saveSearchWithTopicName:(NSString *)topicName
{
    [self saveSearchWithSearchKey:[self searchKeyForTopicName:topicName]];
}
- (void)saveSearchWithUsername:(NSString *)aUsername
{
    [self saveSearchWithSearchKey:[self searchKeyForUsername:aUsername]];
}
- (void)saveSearchWithSearchKey:(NSString *)searchKey
{
    [self.savedSearchKeywords insertObject:searchKey atIndex:0];
    [self notifiesSavedSearchChanged];
}
- (void)removeSavedSearchWithKeyword:(NSString *)keyword
{
    [self removeSavedSearchWithSearchKey:[self searchKeyForKeyword:keyword]];
}
- (void)removeSavedSearchWithTopicName:(NSString *)topicName
{
    [self removeSavedSearchWithSearchKey:[self searchKeyForTopicName:topicName]];
}
- (void)removeSavedSearchWithUsername:(NSString *)aUsername
{
    [self removeSavedSearchWithSearchKey:[self searchKeyForUsername:aUsername]];
}

- (void)removeSavedSearchWithSearchKey:(NSString *)searchKey
{
    [self.savedSearchKeywords removeObject:searchKey];
    [self notifiesSavedSearchChanged];
}
- (void)notifiesSavedSearchChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSavedSearchesDidChangeNotification object:self];
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
    return stream;
}
- (WeiboRepostsStream *)repostsStreamForStatus:(WeiboStatus *)status
{
    WeiboRepostsStream * stream = [WeiboRepostsStream new];
    [stream setBaseStatus:status];
    [stream setAccount:self];
    return stream;
}
- (WeiboLikesStream *)likesStreamForStatus:(WeiboStatus *)status
{
    WeiboLikesStream * stream = [WeiboLikesStream new];
    [stream setBaseStatus:status];
    [stream setAccount:self];
    return stream;
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
    
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(favoriteActionResponse:info:), userInfo);
    
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

- (void)toggleLikeOfStatus:(WeiboStatus *)status
{
    BOOL shouldUnlike = status.liked;
    
    status.liked = !status.liked;
    
    WeiboAPI * api = [self authenticatedSuperpowerRequestWithCompletion:^(id responseObject, id info __attribute__((unused))) {
        if ([responseObject isKindOfClass:[WeiboRequestError class]])
        {
            status.liked = shouldUnlike;
            // TODO: Posts notification here
        }
    }];
    
    if (shouldUnlike)
    {
        [api unlikeStatusID:status.sid];
    }
    else
    {
        [api likeStatusID:status.sid];
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
    else if ([response isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = response;
        NSDictionary * statusDict = [dict objectForKey:@"status"];
        
        WeiboStatus * newStatus = [WeiboStatus objectWithJSONObject:statusDict account:self];
        
        status.favorited = newStatus.favorited;
    }
    
    [self postStatusFavoriteStateChangedNotification:status];
}
- (BOOL)hasFreshTweets
{
    return self.newStatusesCount > 0;
}
- (BOOL)hasFreshMentions
{
    return [self hasFreshStatusMentions] || [self hasFreshCommentMentions];
}
- (BOOL)hasFreshStatusMentions
{
    return self.newStatusMentionsCount > 0;
}
- (BOOL)hasFreshCommentMentions
{
    return self.newCommentMentionsCount > 0;
}
- (BOOL)hasFreshComments
{
    return self.newCommentsCount > 0;
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
        return (NSInteger)self.directMessagesManager.unreadConversations.count;
    }
    
    return _newDirectMessagesCount;
}

- (NSInteger)newStatusesCount
{
    if (self.timelineStream.statuses.count)
    {
        return (NSInteger)self.timelineStream.unreadCount;
    }
    return _newStatusesCount;
}

- (NSInteger)newMentionsCount
{
    return self.newStatusMentionsCount + self.newCommentMentionsCount;
}
- (NSInteger)newStatusMentionsCount
{
    if (self.statusMentionsStream.hasData)
    {
        return (NSInteger)self.statusMentionsStream.unreadCount;
    }
    return _newStatusMentionsCount;
}
- (NSInteger)newCommentMentionsCount
{
    if (self.commentMentionsStream.hasData)
    {
        return (NSInteger)self.commentMentionsStream.unreadCount;
    }
    return _newCommentMentionsCount;
}

- (NSInteger)newCommentsCount
{
    if (self.commentsToMeStream.hasData)
    {
        return (NSInteger)self.commentsToMeStream.unreadCount;
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
    }else if (status.isComment) {
        [api destoryComment:status.sid];
    }else {
        return;
    }
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kWeiboStatusDeleteNotification object:status];
}

@end
