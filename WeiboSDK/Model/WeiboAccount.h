//
//  WeiboAccount.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"
#import "WeiboComposition.h"

@class WeiboUser, WeiboRequestError, WeiboAPI, WTCallback;
@class WeiboTimelineStream, WeiboMentionsStream, WeiboCommentMentionsStream, WeiboCommentsToMeStream, WeiboCommentsByMeStream;
@class WeiboUserTimelineStream, WeiboUnread, WeiboStream;
@class WeiboRepliesStream, WeiboRepostsStream, WeiboStatus, WeiboBaseStatus;
@class WeiboUserStream, WeiboFavoritesStream, WeiboStatusAccountMentionFilter, WeiboDirectMessagesConversationManager, WeiboStatusAdvertisementFilter;

@protocol WeiboAccountDelegate;

extern NSString * const WeiboStatusFavoriteStateDidChangeNotifiaction;

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
    id<WeiboAccountDelegate> _delegate;
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

@property (assign, nonatomic) id<WeiboAccountDelegate> delegate;
@property (readonly, nonatomic) NSString *username;
@property (retain, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *oAuthTokenSecret;
@property (retain, nonatomic) NSString *oAuthToken;
@property (retain, nonatomic) NSString *oAuth2Token;
@property (assign, nonatomic) BOOL tokenExpired;
@property (assign, nonatomic) BOOL superpowerTokenExpired;
@property (assign, nonatomic) NSTimeInterval expireTime;
@property (retain, nonatomic) WeiboUser *user;
@property (readonly, nonatomic) NSString *apiRoot;
@property (retain, nonatomic) NSImage * profileImage;
@property (assign, nonatomic) WeiboNotificationOptions notificationOptions;

@property (nonatomic, retain) NSString * superpowerToken;
@property (nonatomic, retain, readonly) WeiboDirectMessagesConversationManager * directMessagesManager;

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
- (WeiboAPI *)request:(WTCallback *)callback;
- (WeiboAPI *)authenticatedRequest:(WTCallback *)callback;

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
- (void)userWithUsername:(NSString *)screenname callback:(WTCallback *)callback;

#pragma mark -
#pragma mark Account
- (void)myUserDidUpdate:(WeiboUser *)user;
- (void)verifyCredentials:(WTCallback *)callback;
- (void)requestProfileImageWithCallback:(WTCallback *)callback;

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

- (void)toggleFavoriteOfStatus:(WeiboStatus *)status;

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
- (void)refreshDirectMessages;

@property (nonatomic, assign) NSInteger newStatusesCount;
@property (nonatomic, assign, readonly) NSInteger newMentionsCount;
@property (nonatomic, assign) NSInteger newStatusMentionsCount;
@property (nonatomic, assign) NSInteger newCommentMentionsCount;
@property (nonatomic, assign) NSInteger newCommentsCount;
@property (nonatomic, assign) NSInteger newDirectMessagesCount;
@property (nonatomic, assign) NSInteger newFollowersCount;

#pragma mark - Filter

@property (nonatomic, assign) BOOL filterAdvertisements;

@property (nonatomic, retain) NSMutableArray * keywordFilters;
@property (nonatomic, retain) NSMutableArray * userFilters;
@property (nonatomic, retain) NSMutableArray * clientFilters;
@property (nonatomic, retain) NSMutableArray * userHighlighters;

@property (nonatomic, retain) WeiboStatusAccountMentionFilter * mentionHighlighter;
@property (nonatomic, retain) WeiboStatusAdvertisementFilter * advertisementFilter;

@end


@protocol WeiboAccountDelegate <NSObject>
- (void)account:(WeiboAccount *)account didFailToPost:(id<WeiboComposition>)composition errorMessage:(NSString *)message error:(WeiboRequestError *)error;
- (void)account:(WeiboAccount *)account didCheckingUnreadCount:(id)info;
- (void)account:(WeiboAccount *)account finishCheckingUnreadCount:(WeiboUnread *)unread;
@end