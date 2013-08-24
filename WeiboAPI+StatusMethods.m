//
//  WeiboAPI+StatusMethods.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+Private.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboStatus.h"
#import "WeiboList.h"

@implementation WeiboAPI (StatusMethods)

#pragma mark -
#pragma mark Statuses Getting
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count callback:(WTCallback *)callback{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [parameters setValue:[NSString stringWithFormat:@"%lld",since] forKey:@"since_id"];
    [parameters setValue:[NSString stringWithFormat:@"%lld",max] forKey:@"max_id"];
    [parameters setValue:[NSString stringWithFormat:@"%ld",count] forKey:@"count"];
    [parameters setValue:[NSString stringWithFormat:@"%ld",page] forKey:@"page"];
    [self GET:url parameters:parameters callback:callback];
}
- (WTCallback *)statusesResponseCallback
{
    return WTCallbackMake(self, @selector(statusesResponse:info:), nil);
}
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count callback:(WTCallback *)callback{
    [self statusesRequest:url parameters:params sinceID:since maxID:max page:1 count:count callback:callback];
}
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WTCallback * callback = [self statusesResponseCallback];
    [self statusesRequest:url parameters:params sinceID:since maxID:max count:count callback:callback];
}
- (void)statusesResponse:(id)response info:(id)info{
    [WeiboStatus parseStatusesJSON:response callback:responseCallback];
}
- (void)commentsResponse:(id)response info:(id)info{
    [WeiboComment parseCommentsJSON:response callback:responseCallback];
}
- (void)friendsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    [self statusesRequest:@"statuses/friends_timeline.json" parameters:nil sinceID:since maxID:max count:count];
}
- (void)mentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    [self statusesRequest:@"statuses/mentions.json" parameters:nil sinceID:since maxID:max count:count];
}
- (void)commentsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(commentsResponse:info:), nil);
    [self statusesRequest:@"comments/timeline.json" parameters:nil sinceID:since maxID:max count:count callback:callback];
}
- (void)userTimelineForUserID:(WeiboUserID)uid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",uid] forKey:@"user_id"];
    [self statusesRequest:@"statuses/user_timeline.json" parameters:params sinceID:since maxID:max count:count];
}
- (void)userTimelineForUsername:(NSString *)screenname sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    if (!screenname) return;
    NSDictionary * params = [NSDictionary dictionaryWithObject:screenname forKey:@"screen_name"];
    [self statusesRequest:@"statuses/user_timeline.json" parameters:params sinceID:since maxID:max count:count];
}
- (void)repliesForStatusID:(WeiboStatusID)sid page:(NSUInteger)page count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(commentsResponse:info:), [NSNumber numberWithBool:YES]);
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",sid] forKey:@"id"];
    [self statusesRequest:@"statuses/comments.json" parameters:params sinceID:0 maxID:0 page:page count:count callback:callback];
}
- (void)repliesForStatusID:(WeiboStatusID)sid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(commentsResponse:info:), [NSNumber numberWithBool:YES]);
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",sid] forKey:@"id"];
    [self statusesRequest:@"comments/show.json" parameters:params sinceID:since maxID:max page:1 count:count callback:callback];
}
#pragma mark -
#pragma mark Favorites
- (void)favoritesForPage:(NSUInteger)page count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(favoritesResponse:info:), nil);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",page],@"page",[NSString stringWithFormat:@"%ld",count],@"count", nil];
    [self GET:@"favorites.json" parameters:params callback:callback];
}
- (void)favoritesResponse:(id)returnValue info:(id)info{
    [WeiboFavoriteStatus parseStatusesJSON:returnValue callback:responseCallback];
}

- (void)favoriteStatusID:(WeiboStatusID)statusID
{
    WTCallback * callback = WTCallbackMake(self, @selector(favoriteActionResponse:info:), @(YES));
    [self POST:@"favorites/create.json" parameters:@{@"id":@(statusID)} callback:callback];
}
- (void)unfavoriteStatusID:(WeiboStatusID)statusID
{
    WTCallback * callback = WTCallbackMake(self, @selector(favoriteActionResponse:info:), @(NO));
    [self POST:@"favorites/destroy.json" parameters:@{@"id":@(statusID)} callback:callback];
}

- (void)favoriteActionResponse:(id)responseObject info:(id)info
{
    [responseCallback invoke:responseObject];
}

#pragma mark -
#pragma mark Trends
- (void)trendStatusesWithTrend:(NSString *)keyword page:(NSUInteger)page count:(NSUInteger)count{
    WTCallback * callback = [self statusesResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:keyword,@"q",nil];
    [self statusesRequest:@"search/topics.json" parameters:params sinceID:0 maxID:0 page:page count:count callback:callback];
}
- (void)trendsInHourly{
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(trendsResponse:info:) info:nil];
    [self GET:@"trends/hourly.json" parameters:nil callback:callback];
}
- (void)trendsResponse:(id)returnValue info:(id)info{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSDictionary * trends = [[returnValue objectFromJSONString] objectForKey:@"trends"];
        NSArray * keys = [trends allKeys];
        NSArray * items = [trends objectForKey:[keys objectAtIndex:0]];
        NSMutableArray * result = [NSMutableArray array];
        for (NSDictionary * item in items) {
            [result addObject:[item objectForKey:@"query"]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [responseCallback invoke:result];
        });
    });
}

#pragma mark -
#pragma mark Lists
/**
 error response:{"error":"access_denied","error_code":21330,"request":"/2/friendships/groups.json"}
 */
- (void)lists
{
    [self GET:@"friendships/groups.json" parameters:nil callback:WTCallbackMake(self, @selector(listsResponse:info:), nil)];
}
- (void)listsResponse:(id)response info:(id)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * dict = [response objectFromJSONString];
        NSArray * listDatas = [dict objectForKey:@"lists"];
        id result = nil;
        if ([listDatas isKindOfClass:[NSArray class]])
        {
            NSMutableArray * lists = [NSMutableArray array];
            for (NSDictionary * listData in listDatas)
            {
                [lists addObject:[WeiboList listWithDictionary:listData]];
            }
            result = lists;
        }
        else
        {
            result = @[];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [responseCallback invoke:result];
        });
    });
}

- (void)listStatuses:(NSString *)listID sinceID:(WeiboStatusID)sinceID maxID:(WeiboStatusID)maxID count:(NSInteger)count page:(NSInteger)page
{
    WTCallback * callback = [self statusesResponseCallback];
    NSDictionary * params = @{@"list_id" : listID};
    [self statusesRequest:@"friendships/groups/timeline.json" parameters:params sinceID:sinceID maxID:maxID page:page count:count callback:callback];
}

#pragma mark -
#pragma mark Weibo Access
- (void)statuseResponse:(id)response info:(id)info{
    [responseCallback invoke:response];
}
- (void)commentResponse:(id)response info:(id)info{
    [responseCallback invoke:response];
}
- (WTCallback *)statusResponseCallback{
    return WTCallbackMake(self, @selector(statuseResponse:info:), nil);
}
- (WTCallback *)commentResponseCallback{
    return WTCallbackMake(self, @selector(commentResponseCallback), nil);
}
- (void)repost:(NSString *)text repostingID:(WeiboStatusID)repostID shouldComment:(BOOL)comment
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeNewTweet];
    WTCallback * callback = WTCallbackMake(self, @selector(updated:info:), type);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             text, @"status",
                             [NSString stringWithFormat:@"%lld",repostID], @"id", nil];
    NSString * url = @"statuses/repost.json";
    [self POST:url parameters:params callback:callback];
}

- (void)update:(NSString *)text imageData:(NSData *)image latitude:(double)latValue longitude:(double)longValue
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeNewTweet];
    WTCallback * callback = WTCallbackMake(self, @selector(updated:info:), type);
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:text forKey:@"status"];
    if (latValue > 0 || longValue > 0) {
        [params setObject:[NSString stringWithFormat:@"%f",latValue] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f",longValue] forKey:@"long"];
    }
    NSDictionary * parts = nil;
    NSString * url = @"statuses/update.json";
    if (image)
    {
        parts = [NSDictionary dictionaryWithObject:image forKey:@"pic"];
        url = @"statuses/upload.json";
    }
    [self POST:url parameters:params multipartFormData:parts callback:callback];
}
- (void)update:(NSString *)text inRetweetStatusID:(WeiboStatusID)reply
{
    [self repost:text repostingID:reply shouldComment:NO];
}
- (void)updated:(id)response info:(id)info
{
    WeiboCompositionType type = [info integerValue];
    [authenticateWithAccount refreshTimelineForType:type];
    [responseCallback invoke:response];
}
- (void)destoryStatus:(WeiboStatusID)sid{
    WTCallback * callback = [self statusResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",sid],@"id", nil];
    NSString * url = @"statuses/destroy.json";
    [self POST:url parameters:params callback:callback];
}
- (void)destoryComment:(WeiboStatusID)sid{
    WTCallback * callback = [self commentResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",sid],@"cid", nil];
    NSString * url = @"comments/destroy.json";
    [self POST:url parameters:params callback:callback];
}
- (void)reply:(NSString *)text toStatusID:(WeiboStatusID)sid toCommentID:(WeiboStatusID)cid
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeComment];
    WTCallback * callback = WTCallbackMake(self, @selector(updated:info:), type);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             text, @"comment",
                             [NSString stringWithFormat:@"%lld",sid],@"id",
                             [NSString stringWithFormat:@"%lld",cid],@"cid", nil];
    NSString * url = @"comments/create.json";
    if (cid > 0) {
        url = @"comments/reply.json";
    }
    [self POST:url parameters:params multipartFormData:nil callback:callback];
}
- (void)updateWithComposition:(id<WeiboComposition>)composition
{
    if (composition.replyToStatus)
    {
        WeiboStatusID toSID = composition.replyToStatus.sid, toCID = 0;
        if ([composition.replyToStatus isKindOfClass:[WeiboComment class]])
        {
            WeiboComment * comment = (WeiboComment *)composition.replyToStatus;
            toCID = toSID;
            toSID = comment.replyToStatus.sid;
        }
        [self reply:composition.text toStatusID:toSID toCommentID:toCID];
    }
    else if (composition.retweetingStatus)
    {
        WeiboStatus * status = (WeiboStatus *)composition.retweetingStatus;
        
        if ([status isKindOfClass:[WeiboStatus class]])
        {
            if (status.retweetedStatus)
            {
                status = status.retweetedStatus;
            }
        }
        
        [self repost:composition.text repostingID:status.sid shouldComment:NO];
    }
    else
    {
        [self update:composition.text imageData:composition.imageData latitude:0 longitude:0];
    }
}

@end
