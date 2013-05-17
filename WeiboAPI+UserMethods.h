//
//  WeiboAPI+UserMethods.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (UserMethods)

#pragma mark -
#pragma mark User Access
- (void)verifyCredentials;
- (void)userWithID:(WeiboUserID)uid;
- (void)userWithUsername:(NSString *)screenname;

#pragma mark -
#pragma mark User Relationship
- (void)followUserID:(WeiboUserID)uid;
- (void)followUsername:(NSString *)screenname;
- (void)unfollowUserID:(WeiboUserID)uid;
- (void)unfollowUsername:(NSString *)screenname;
- (void)lookupRelationships:(WeiboUserID)tuid;
- (void)userID:(WeiboUserID)suid followsUserID:(WeiboUserID)tuid;
- (void)friendshipForSourceUserID:(WeiboUserID)suid targetUserID:(WeiboUserID)tuid;
- (void)friendshipForSourceUsername:(NSString *)sscreenname targetUsername:(NSString *)tscreenname;

#pragma mark -
#pragma mark User Lists
- (void)followersForUsername:(NSString *)screenname cursor:(WeiboUserID)cursor;
- (void)followersForUserID:(WeiboUserID)userid cursor:(WeiboUserID)cursor;
- (void)friendsForUsername:(NSString *)screenname cursor:(WeiboUserID)cursor;
- (void)friendsForUserID:(WeiboUserID)userid cursor:(WeiboUserID)cursor;

@end
