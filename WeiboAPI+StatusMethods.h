//
//  WeiboAPI+StatusMethods.h
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

#define WeiboDummyListIDFirendCircle @"__friend_circle__"

@interface WeiboAPI (StatusMethods)

#pragma mark -
#pragma mark Statuses Getting
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (WTCallback *)statusesResponseCallback;
- (void)friendsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)mentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count;
- (void)commentMentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count;
- (void)commentsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count;
- (void)commentsToMeSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count;
- (void)commentsByMeSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count;

- (void)userTimelineForUserID:(WeiboUserID)uid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)userTimelineForUsername:(NSString *)screenname sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)repliesForStatusID:(WeiboStatusID)sid page:(NSUInteger)page count:(NSUInteger)count __attribute__((deprecated));
- (void)repliesForStatusID:(WeiboStatusID)sid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)repostsForStatusID:(WeiboStatusID)sid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;
- (void)commentConversationWithCommentID:(WeiboStatusID)cid;
- (void)commentWithID:(WeiboStatusID)cid;

#pragma mark -
#pragma mark Favorites
- (void)favoritesForPage:(NSUInteger)page count:(NSUInteger)count;
- (void)favoriteStatusID:(WeiboStatusID)statusID;
- (void)unfavoriteStatusID:(WeiboStatusID)statusID;

#pragma mark -
#pragma mark Search
- (void)trendStatusesWithTrend:(NSString *)keyword page:(NSUInteger)page count:(NSUInteger)count;
- (void)trendsInHourly;
- (void)statusesWithKeyword:(NSString *)keyword startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime count:(NSUInteger)count;

#pragma mark -
#pragma mark Lists
- (void)lists;
- (void)listStatuses:(NSString *)listID sinceID:(WeiboStatusID)sinceID maxID:(WeiboStatusID)maxID count:(NSInteger)count page:(NSInteger)page;
- (void)friendCircleTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count;

#pragma mark -
#pragma mark Weibo Access
- (WTCallback *)statusResponseCallback;
- (void)updateWithComposition:(id<WeiboComposition>)composition;
- (void)update:(NSString *)text imageData:(NSData *)image latitude:(double)latValue longitude:(double)longValue;
- (void)update:(NSString *)text inRetweetStatusID:(WeiboStatusID)reply;
- (void)destoryStatus:(WeiboStatusID)sid;
- (void)destoryComment:(WeiboStatusID)sid;
- (void)reply:(NSString *)text toStatusID:(WeiboStatusID)sid toCommentID:(WeiboStatusID)cid;

@end
