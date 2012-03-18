//
//  WeiboAPI.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboConstants.h"

@class WTCallback, WTHTTPRequest, WeiboAccount, WeiboComposition;

@interface WeiboAPI : NSObject {
    NSString * apiRoot;
    WeiboAccount * authenticateWithAccount;
    WTCallback * responseCallback;
}

+ (id)requestWithAPIRoot:(NSString *)root callback:(WTCallback *)callback;
+ (id)authenticatedRequestWithAPIRoot:(NSString *)root 
                              account:(WeiboAccount *)account 
                             callback:(WTCallback *)callback;
- (id)initWithAccount:(WeiboAccount *)account
              apiRoot:(NSString *)root 
             callback:(WTCallback *)callback;

- (WTHTTPRequest *)baseRequestWithPartialURL:(NSString *)partialUrl;
- (NSString *)keychainService;

#pragma mark -
#pragma mark Statuses Getting
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params 
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)friendsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)mentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)commentsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)userTimelineForUserID:(WeiboUserID)uid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)userTimelineForUsername:(NSString *)screenname sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)repliesForStatusID:(WeiboStatusID)sid page:(NSUInteger)page count:(NSUInteger)count;
#pragma mark -
#pragma mark Weibo Access
- (WTCallback *)statuseResponseCallback;
- (void)updateWithComposition:(WeiboComposition *)composition;
- (void)update:(NSString *)text inReplyToStatusID:(WeiboStatusID)reply imageData:(NSData *)image
      latitude:(double)latValue longitude:(double)longValue;
- (void)update:(NSString *)text inReplyToStatusID:(WeiboStatusID)reply;
- (void)destoryStatus:(WeiboStatusID)sid;
- (void)destoryComment:(WeiboStatusID)sid;
- (void)reply:(NSString *)text toStatusID:(WeiboStatusID)sid toCommentID:(WeiboStatusID)cid;
#pragma mark -
#pragma mark User Access
- (void)verifyCredentials;
- (void)userWithID:(WeiboUserID)uid;
- (void)userWithUsername:(NSString *)screenname;
#pragma mark -
#pragma mark Relationship
- (void)followUserID:(WeiboUserID)uid;
- (void)followUsername:(NSString *)screenname;
- (void)unfollowUserID:(WeiboUserID)uid;
- (void)unfollowUsername:(NSString *)screenname;
- (void)lookupRelationships:(WeiboUserID)tuid;
- (void)userID:(WeiboUserID)suid followsUserID:(WeiboUserID)tuid;
- (void)friendshipForSourceUserID:(WeiboUserID)suid targetUserID:(WeiboUserID)tuid;
- (void)friendshipForSourceUsername:(NSString *)sscreenname targetUsername:(NSString *)tscreenname;
- (void)friendshipInfo:(id)response info:(id)info;
- (void)friendshipExists:(id)response info:(id)info;
#pragma mark -
#pragma mark Direct Message
- (void)directMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)directMessageResponse:(id)response info:(id)info;
- (void)directMessagesResponse:(id)response info:(id)info;
#pragma mark -
#pragma mark Other
- (void)unreadCountSinceID:(WeiboStatusID)since;
- (void)unreadCount;
- (void)unreadCountResponse:(id)response info:(id)info;
- (void)resetUnreadWithType:(WeiboUnreadCountType)type;
- (void)resetUnreadResponse:(id)response info:(id)info;
#pragma mark -
#pragma mark oAuth (xAuth)
- (void)xAuthRequestAccessTokens;
- (void)xAuthMigrateResponse:(id)response info:(id)info;

@end