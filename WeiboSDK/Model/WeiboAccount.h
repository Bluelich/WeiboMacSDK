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
@class WeiboTimelineStream, WeiboMentionsStream, WeiboCommentsTimelineStream;
@class WeiboUserTimelineStream, WeiboUnread, WeiboStream;
@class WeiboRepliesStream, WeiboStatus, WeiboBaseStatus;
@class WeiboUserStream, WeiboFavoritesStream;

@protocol WeiboAccountDelegate;

@interface WeiboAccount : NSObject <NSCoding> {
    NSString * username;
    NSString * password;
    NSString * oAuthToken;
    NSString * oAuthTokenSecret;
    NSMutableDictionary *usersByUsername;
    NSString * apiRoot;
    WeiboUser * user;
    WeiboTimelineStream * timelineStream;
    WeiboMentionsStream * mentionsStream;
    WeiboCommentsTimelineStream * commentsTimelineStream;
    WeiboFavoritesStream * favoritesStream;
    NSMutableArray *outbox;
    id<WeiboAccountDelegate> _delegate;
    WeiboNotificationOptions notificationOptions;
    NSMutableDictionary * userDetailsStreamsCache;
    
    NSMutableArray * _lists;
    
    struct {
        unsigned int newDirectMessages:1;
        unsigned int newFollowers:1;
        // When mentions stream or comments stream not loaded
        // and account has unread mentions or comments
        // use following flags to store and detect.
        unsigned int newMentions:1;
        unsigned int newCommnets:1;
    } _notificationFlags;
    
    struct {
        unsigned int requestingAvatar: 1;
        unsigned int loadingLists:1;
    } _flags;
}

@property (assign, nonatomic) id<WeiboAccountDelegate> delegate;
@property (readonly, nonatomic) NSString *username;
@property (retain, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *oAuthTokenSecret;
@property (retain, nonatomic) NSString *oAuthToken;
@property (retain, nonatomic) NSString *oAuth2Token;
@property (assign, nonatomic) BOOL tokenExpired;
@property (assign, nonatomic) NSTimeInterval expireTime;
@property (retain, nonatomic) WeiboUser *user;
@property (readonly, nonatomic) NSString *apiRoot;
@property (retain, nonatomic) NSImage * profileImage;
@property (assign, nonatomic) WeiboNotificationOptions notificationOptions;

#pragma mark -
#pragma mark Life Cycle
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword apiRoot:(NSString *)root;
- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword;
- (id)initWithUserID:(WeiboUserID)userID oAuth2Token:(NSString *)token;

#pragma mark -
#pragma mark Accessor

+ (NSString *)keyChainAccountForUserID:(WeiboUserID)userID;

- (WeiboTimelineStream *) timelineStream;
- (WeiboMentionsStream *) mentionsStream;
- (WeiboCommentsTimelineStream *) commentsTimelineStream;
- (WeiboFavoritesStream *) favoritesStream;

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
- (BOOL)hasFreshTweets;
- (BOOL)hasFreshMentions;
- (BOOL)hasFreshComments;
- (BOOL)hasFreshDirectMessages;
- (BOOL)hasNewFollowers;
- (BOOL)hasAnythingUnread;
- (BOOL)hasFreshAnythingApplicableToStatusItem;
- (BOOL)hasFreshAnythingApplicableToDockBadge;
- (void)deleteStatus:(WeiboBaseStatus *)status;

- (void)setHasNewDirectMessages:(BOOL)hasNew;
- (void)setHasNewFollowers:(BOOL)hasNew;
- (void)setHasNewMentions:(BOOL)hasNewMentions;
- (void)setHasNewComments:(BOOL)hasNewComments;

@end


@protocol WeiboAccountDelegate <NSObject>
- (void)account:(WeiboAccount *)account didFailToPost:(id<WeiboComposition>)composition errorMessage:(NSString *)message error:(WeiboRequestError *)error;
- (void)account:(WeiboAccount *)account didCheckingUnreadCount:(id)info;
- (void)account:(WeiboAccount *)account finishCheckingUnreadCount:(WeiboUnread *)unread;
@end
