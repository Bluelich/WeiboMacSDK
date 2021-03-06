//
//  WeiboAccount.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboComposition.h"
#import "WeiboCallback.h"

@class WeiboUser, WeiboRequestError, WeiboAPI, WeiboCallback;
@class WeiboTimelineStream, WeiboMentionsStream, WeiboCommentMentionsStream, WeiboCommentsToMeStream, WeiboCommentsByMeStream;
@class WeiboUserTimelineStream, WeiboUnread, WeiboStream;
@class WeiboRepliesStream, WeiboRepostsStream, WeiboStatus, WeiboBaseStatus, WeiboLikesStream;
@class WeiboUserStream, WeiboFavoritesStream, WeiboStatusAccountMentionFilter, WeiboPrivateMessagesConversationManager, WeiboPublicMessagesConversationManager, WeiboStatusAdvertisementFilter, WeiboSavedSearch;

@protocol WeiboAccountDelegate;

extern NSString * const WeiboStatusFavoriteStateDidChangeNotifiaction;
extern NSString * const WeiboAccountSavedSearchesDidChangeNotification;
extern NSString * const WeiboUserRemarkDidUpdateNotification;
extern NSString * const WeiboAccountDidSentCompositionNotification;
extern NSString * const WeiboAccountDidSentCompositionNotificationCompositionKey;

@interface WeiboAccount : NSObject <NSCoding>
{
    NSString * username;
    NSString * password;
    NSString * oAuthToken;
    NSString * oAuthTokenSecret;
    NSMutableDictionary *usersByUsername;
    NSString * apiRoot;
    WeiboUser * user;
    WeiboTimelineStream * timelineStream;
    WeiboMentionsStream * statusMentionsStream;
    WeiboCommentMentionsStream * commentMentionsStream;
    WeiboCommentsToMeStream * commentsToMeStream;
    WeiboCommentsByMeStream * commentsByMeStream;
    WeiboFavoritesStream * favoritesStream;
    
    NSMutableArray *outbox;
    id<WeiboAccountDelegate> __unsafe_unretained _delegate;
    WeiboNotificationOptions notificationOptions;
    NSMutableDictionary * userDetailsStreamsCache;
    
    NSMutableArray * _lists;
    
    struct {
        unsigned int requestingAvatar: 1;
        unsigned int loadingLists:1;
        unsigned int listsLoaded:1;
        unsigned int listsAccessDenied:1;
        unsigned int superpowerAuthorizing:1;
    } _flags;
}

@property (unsafe_unretained, nonatomic) id<WeiboAccountDelegate> delegate;
@property (readonly, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *oAuthTokenSecret;
@property (strong, nonatomic) NSString *oAuthToken;
@property (strong, nonatomic) NSString *oAuth2Token;
@property (assign, nonatomic) BOOL tokenExpired;
@property (assign, nonatomic) BOOL superpowerTokenExpired;
@property (assign, nonatomic) NSTimeInterval expireTime;
@property (strong, nonatomic) WeiboUser *user;
@property (readonly, nonatomic) NSString *apiRoot;
@property (strong, nonatomic) NSImage * profileImage;
@property (assign, nonatomic) WeiboNotificationOptions notificationOptions;

@property (nonatomic, strong) NSString * superpowerToken;
@property (nonatomic, strong, readonly) WeiboPrivateMessagesConversationManager * privateMessagesManager;
@property (nonatomic, strong, readonly) WeiboPublicMessagesConversationManager * publicMessagesManager;

#pragma mark -
#pragma mark Life Cycle
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword apiRoot:(NSString *)root;
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword;
- (id)initWithUserID:(WeiboUserID)userID oAuth2Token:(NSString *)token;

#pragma mark -
#pragma mark Accessor

+ (NSString *)keyChainAccountForUserID:(WeiboUserID)userID;

- (WeiboTimelineStream *)timelineStream;
- (WeiboMentionsStream *)statusMentionsStream;
- (WeiboCommentMentionsStream *)commentMentionsStream;
- (WeiboCommentsByMeStream *)commentsByMeStream;
- (WeiboCommentsToMeStream *)commentsToMeStream;
- (WeiboFavoritesStream *)favoritesStream;

#pragma mark -
#pragma mark Core Methods
- (NSString *)keychainService;
- (BOOL)isEqualToAccount:(WeiboAccount *)anotherAccount;
- (void)updateWithAccount:(WeiboAccount *)account;
- (WeiboAPI *)request:(WeiboCallback *)callback;
- (WeiboAPI *)authenticatedRequest:(WeiboCallback *)callback;
- (WeiboAPI *)authenticatedRequestWithCompletion:(WeiboCallbackBlock)completion;

#pragma mark -
#pragma mark Timeline
- (void)forceRefreshTimelines;
- (void)refreshTimelineForType:(WeiboCompositionType)type;
- (void)refreshMentions;
- (void)refreshComments;
- (void)refreshTimelines;
- (void)resetUnreadCountWithType:(WeiboUnreadCountType)type;

#pragma mark -
#pragma mark Composition
- (void)sendCompletedComposition:(id<WeiboComposition>)composition;

#pragma mark -
#pragma mark User
- (void)userWithUsername:(NSString *)screenname callback:(WeiboCallback *)callback;

#pragma mark -
#pragma mark Account
- (void)myUserDidUpdate:(WeiboUser *)user;
- (void)verifyCredentials:(WeiboCallback *)callback;
- (void)requestProfileImageWithCallback:(WeiboCallback *)callback;

#pragma mark -
#pragma mark User Detail Streams
- (WeiboUserTimelineStream *)timelineStreamForUser:(WeiboUser *)aUser;


#pragma mark - Cache
- (void)pruneStatusCache;
- (void)pruneUserCache;
- (void)cacheUser:(WeiboUser *)newUser;

#pragma mark - Others
- (WeiboRepliesStream *)repliesStreamForStatus:(WeiboStatus *)status;
- (WeiboRepostsStream *)repostsStreamForStatus:(WeiboStatus *)status;
- (WeiboLikesStream *)likesStreamForStatus:(WeiboStatus *)status;

- (void)toggleFavoriteOfStatus:(WeiboStatus *)status;
- (void)toggleLikeOfStatus:(WeiboStatus *)status;

- (BOOL)hasFreshTweets;
- (BOOL)hasFreshMentions;
- (BOOL)hasFreshStatusMentions;
- (BOOL)hasFreshCommentMentions;
- (BOOL)hasFreshComments;
- (BOOL)hasFreshDirectMessages;
- (BOOL)hasNewFollowers;
- (BOOL)hasAnythingUnread;
- (BOOL)hasFreshAnythingApplicableToStatusItem;
- (BOOL)hasFreshAnythingApplicableToDockBadge;
- (NSInteger)unreadCountForDockBadge;

- (void)deleteStatus:(WeiboBaseStatus *)status;

- (void)willSaveToDisk;
- (void)didRestoreFromDisk;
- (void)refreshPrivateMessages;
- (void)refreshPublicMessage;

@property (nonatomic, assign) NSInteger newStatusesCount;
@property (nonatomic, assign, readonly) NSInteger newMentionsCount;
@property (nonatomic, assign) NSInteger newStatusMentionsCount;
@property (nonatomic, assign) NSInteger newCommentMentionsCount;
@property (nonatomic, assign) NSInteger newCommentsCount;
@property (nonatomic, assign) NSInteger newDirectMessagesCount;
@property (nonatomic, assign) NSInteger newPublicMessagesCount;
@property (nonatomic, assign) NSInteger newFollowersCount;

#pragma mark - Saved Searches

- (NSArray *)savedSearches;

- (NSString *)searchKeyForKeyword:(NSString *)keyword;
- (NSString *)searchKeyForUsername:(NSString *)aUsername;
- (NSString *)searchKeyForTopicName:(NSString *)aTopicname;

- (NSString *)searchKeywordForSearchKey:(NSString *)searchKey;

- (BOOL)isUserSearch:(NSString *)searchKey;
- (BOOL)isTopicSearch:(NSString *)searchKey;
- (BOOL)isKeywordSearch:(NSString *)searchKey;

- (void)saveSearchWithSearchKey:(NSString *)searchKey;
- (void)saveSearchWithKeyword:(NSString *)keyword;
- (void)saveSearchWithTopicName:(NSString *)topicName;
- (void)saveSearchWithUsername:(NSString *)username;
- (void)removeSavedSearchWithSearchKey:(NSString *)searchKey;
- (void)removeSavedSearchWithKeyword:(NSString *)keyword;
- (void)removeSavedSearchWithTopicName:(NSString *)topicName;
- (void)removeSavedSearchWithUsername:(NSString *)username;

#pragma mark - Filter

@property (nonatomic, assign) BOOL filterAdvertisements;

@property (nonatomic, strong) NSMutableArray * keywordFilters;
@property (nonatomic, strong) NSMutableArray * userFilters;
@property (nonatomic, strong) NSMutableArray * clientFilters;
@property (nonatomic, strong) NSMutableArray * userHighlighters;

@property (nonatomic, strong) WeiboStatusAccountMentionFilter * mentionHighlighter;
@property (nonatomic, strong) WeiboStatusAdvertisementFilter * advertisementFilter;

@end


@protocol WeiboAccountDelegate <NSObject>
- (void)account:(WeiboAccount *)account didFailToPost:(id<WeiboComposition>)composition errorMessage:(NSString *)message error:(WeiboRequestError *)error;
- (void)account:(WeiboAccount *)account didCheckingUnreadCount:(id)info;
- (void)account:(WeiboAccount *)account finishCheckingUnreadCount:(WeiboUnread *)unread;
@end
