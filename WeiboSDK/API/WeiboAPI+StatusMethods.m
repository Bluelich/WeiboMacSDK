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
#import "WeiboLikeStatus.h"
#import "WeiboUploadImage.h"
#import "NSArray+WeiboAdditions.h"

@implementation WeiboAPI (StatusMethods)

#pragma mark -
#pragma mark Statuses Getting
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count callback:(WeiboCallback *)callback{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [parameters setValue:[NSString stringWithFormat:@"%lld",since] forKey:@"since_id"];
    [parameters setValue:[NSString stringWithFormat:@"%lld",max] forKey:@"max_id"];
    [parameters setValue:[NSString stringWithFormat:@"%ld",count] forKey:@"count"];
    [parameters setValue:[NSString stringWithFormat:@"%ld",page] forKey:@"page"];
    [self GET:url parameters:parameters callback:callback];
}
- (WeiboCallback *)statusesResponseCallback
{
    return WeiboCallbackMake(self, @selector(statusesResponse:info:), nil);
}
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count callback:(WeiboCallback *)callback{
    [self statusesRequest:url parameters:params sinceID:since maxID:max page:1 count:count callback:callback];
}
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WeiboCallback * callback = [self statusesResponseCallback];
    [self statusesRequest:url parameters:params sinceID:since maxID:max count:count callback:callback];
}
- (void)statusesResponse:(id)response info:(id)info
{
    [WeiboStatus parseObjectsWithJSONObject:response account:authenticateWithAccount rootKey:info[@"rootKey"] callback:responseCallback];
}
- (void)commentsResponse:(id)response info:(id __attribute__((unused)))info{
    [WeiboComment parseObjectsWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}
- (void)friendsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    [self statusesRequest:@"statuses/friends_timeline.json" parameters:nil sinceID:since maxID:max count:count];
}
- (void)mentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count{
    WeiboCallback * callback = [self statusesResponseCallback];
    [self statusesRequest:@"statuses/mentions.json" parameters:nil sinceID:since maxID:max page:page count:count callback:callback];
}
- (void)commentMentionsSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), nil);
    [self statusesRequest:@"comments/mentions.json" parameters:nil sinceID:since maxID:max page:page count:count callback:callback];
}
- (void)commentsTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), nil);
    [self statusesRequest:@"comments/timeline.json" parameters:nil sinceID:since maxID:max page:page count:count callback:callback];
}
- (void)commentsToMeSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), nil);
    [self statusesRequest:@"comments/to_me.json" parameters:nil sinceID:since maxID:max page:page count:count callback:callback];
}
- (void)commentsByMeSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max page:(NSUInteger)page count:(NSUInteger)count
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), nil);
    [self statusesRequest:@"comments/by_me.json" parameters:nil sinceID:since maxID:max page:page count:count callback:callback];
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
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), [NSNumber numberWithBool:YES]);
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",sid] forKey:@"id"];
    [self statusesRequest:@"statuses/comments.json" parameters:params sinceID:0 maxID:0 page:page count:count callback:callback];
}
- (void)repliesForStatusID:(WeiboStatusID)sid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentsResponse:info:), [NSNumber numberWithBool:YES]);
    NSDictionary * params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",sid] forKey:@"id"];
    [self statusesRequest:@"comments/show.json" parameters:params sinceID:since maxID:max page:1 count:count callback:callback];
}
- (void)repostsForStatusID:(WeiboStatusID)sid sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count
{
    NSDictionary * params = @{@"id": @(sid)};

    [self statusesRequest:@"statuses/repost_timeline.json" parameters:params sinceID:since maxID:max count:count callback:WeiboCallbackMake(self, @selector(statusesResponse:info:), @{@"rootKey": @"reposts"})];
}
- (void)commentConversationWithCommentID:(WeiboStatusID __attribute__((unused)))cid
{
    WeiboUnimplementedMethod
    
    // This API is no longer exist
    /*
    WTCallback * callback = WTCallbackMake(self, @selector(commentsResponse:info:), @(YES));
    NSDictionary * params = @{@"cid":@(cid),@"count":@10};
    
    [self GET:@"comments/conversation.json" parameters:params callback:callback];
     */
}
- (void)commentWithID:(WeiboStatusID)cid
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(commentArrayResponse:info:), nil);
    NSDictionary * params = @{@"cids":@(cid)};
    [self GET:@"comments/show_batch.json" parameters:params callback:callback];
}
- (void)commentArrayResponse:(id)response info:(id)info
{
    [WeiboComment parseObjectsWithJSONObject:response account:authenticateWithAccount rootKey:info[@"rootKey"] callback:responseCallback];
}

#pragma mark -
#pragma mark Favorites
- (void)favoritesForPage:(NSUInteger)page count:(NSUInteger)count{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(favoritesResponse:info:), nil);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",page],@"page",[NSString stringWithFormat:@"%ld",count],@"count", nil];
    [self GET:@"favorites.json" parameters:params callback:callback];
}
- (void)favoritesResponse:(id)returnValue info:(id __attribute__((unused)))info
{
    [WeiboFavoriteStatus parseObjectsWithJSONObject:returnValue account:authenticateWithAccount callback:responseCallback];
}

- (void)favoriteStatusID:(WeiboStatusID)statusID
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(favoriteActionResponse:info:), @(YES));
    [self POST:@"favorites/create.json" parameters:@{@"id":@(statusID)} callback:callback];
}
- (void)unfavoriteStatusID:(WeiboStatusID)statusID
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(favoriteActionResponse:info:), @(NO));
    [self POST:@"favorites/destroy.json" parameters:@{@"id":@(statusID)} callback:callback];
}

- (void)favoriteActionResponse:(id)responseObject info:(id __attribute__((unused)))info
{
    [responseCallback invoke:responseObject];
}

#pragma mark - Like
- (void)likeListForStautsID:(WeiboStatusID)statusID page:(NSUInteger)page count:(NSUInteger)count
{
    [self GET:@"attitudes/show.json" parameters:@{@"id": @(statusID), @"count": @(count), @"page": @(page)} callback:WeiboBlockCallback(^(id responseObject, id info __attribute__((unused))) {
        [WeiboLikeStatus parseObjectsWithJSONObject:responseObject account:self->authenticateWithAccount callback:self->responseCallback];
    }, nil)];
}
- (void)likeStatusID:(WeiboStatusID)statusID
{
    [self POST:@"attitudes/create.json" parameters:@{@"id": @(statusID), @"attitude": @"heart"} callback:[self likeActionCallback]];
}
- (void)unlikeStatusID:(WeiboStatusID)statusID
{
    [self POST:@"attitudes/destroy.json" parameters:@{@"id": @(statusID), @"attitude": @"heart"} callback:[self likeActionCallback]];
}
- (WeiboCallback *)likeActionCallback
{
    return WeiboBlockCallback(^(id responseObject, id info __attribute__((unused))) {
        [self->responseCallback invoke:responseObject];
    }, nil);
}

#pragma mark -
#pragma mark Trends
- (void)trendStatusesWithTrend:(NSString *)keyword page:(NSUInteger)page count:(NSUInteger)count{
    WeiboCallback * callback = [self statusesResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:keyword,@"q",nil];
    [self statusesRequest:@"search/topics.json" parameters:params sinceID:0 maxID:0 page:page count:count callback:callback];
}
- (void)statusesWithKeyword:(NSString *)keyword startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime count:(NSUInteger)count
{
    WeiboCallback * callback = [self statusesResponseCallback];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:keyword forKey:@"q"];
    
    if (startTime) [params setObject:@(startTime) forKey:@"starttime"];
    if (endTime) [params setObject:@(endTime) forKey:@"endtime"];
    if (count) [params setObject:@(count) forKey:@"count"];
    
    [self GET:@"search/statuses.json" parameters:params callback:callback];
}

- (void)trendsInHourly{
    WeiboCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(trendsResponse:info:) info:nil];
    [self GET:@"trends/hourly.json" parameters:nil callback:callback];
}
- (void)trendsResponse:(id)returnValue info:(id __attribute__((unused)))info{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSDictionary * trends = [returnValue objectForKey:@"trends"];
        NSArray * keys = [trends allKeys];
        NSArray * items = [trends objectForKey:[keys objectAtIndex:0]];
        NSMutableArray * result = [NSMutableArray array];
        for (NSDictionary * item in items) {
            [result addObject:[item objectForKey:@"query"]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self->responseCallback invoke:result];
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
    [self GET:@"friendships/groups.json" parameters:nil callback:WeiboCallbackMake(self, @selector(listsResponse:info:), nil)];
}
- (void)listsResponse:(id)response info:(id __attribute__((unused)))info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * dict = response;
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
            [self->responseCallback invoke:result];
        });
    });
}

- (void)listStatuses:(NSString *)listID sinceID:(WeiboStatusID)sinceID maxID:(WeiboStatusID)maxID count:(NSUInteger)count page:(NSUInteger)page
{
    if ([listID isEqual:WeiboDummyListIDFirendCircle])
    {
        [self friendCircleTimelineSinceID:sinceID maxID:maxID count:count];
    }
    else
    {
        WeiboCallback * callback = [self statusesResponseCallback];
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:listID, @"list_id",nil];
        [self statusesRequest:@"friendships/groups/timeline.json" parameters:params sinceID:sinceID maxID:maxID page:page count:count callback:callback];
    }
}
- (void)friendCircleTimelineSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count
{
    [self statusesRequest:@"statuses/bilateral_timeline.json" parameters:@{@"feature": @"1"} sinceID:since maxID:max count:count];
}

#pragma mark -
#pragma mark - Hot 

- (void)hotStatusesForPage:(NSInteger __attribute__((unused)))page
{
    WeiboUnimplementedMethod
//    if (!page) page = 1;
//    
//    WeiboHTTPRequest * request = [WeiboHTTPRequest requestWithURL:[NSURL URLWithString:@"http://m.weibo.cn/hot/mblog"]];
//    request.parameters = @{@"catId": @9999, @"page": @(page)};
//    
//    [request startRequest];
}

#pragma mark -
#pragma mark Weibo Access
- (void)statuseResponse:(id)response info:(id __attribute__((unused)))info{
    [responseCallback invoke:response];
}
- (void)commentResponse:(id)response info:(id __attribute__((unused)))info
{
    [responseCallback invoke:response];
}
- (WeiboCallback *)statusResponseCallback{
    return WeiboCallbackMake(self, @selector(statuseResponse:info:), nil);
}
- (WeiboCallback *)commentResponseCallback{
    return WeiboCallbackMake(self, @selector(commentResponse:info:), nil);
}
- (void)repost:(NSString *)text repostingID:(WeiboStatusID)repostID shouldComment:(BOOL)comment
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeNewTweet];
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(updated:info:), type);
    if (!text) text = @"";
    NSDictionary * params = @{@"status" : text,
                              @"id": @(repostID),
                              @"is_comment": @(comment ? 1 : 0)};
    NSString * url = @"statuses/repost.json";
    [self POST:url parameters:params callback:callback];
}

- (void)update:(NSString *)text imageData:(NSData *)image latitude:(double)latValue longitude:(double)longValue
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeNewTweet];
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(updated:info:), type);
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:text forKey:@"status"];
    if (latValue || longValue)
    {
        [params setObject:@(latValue) forKey:@"lat"];
        [params setObject:@(longValue) forKey:@"long"];
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

- (void)update:(NSString *)text imageIDs:(NSArray *)picIDs latitude:(double)latValue longitude:(double)longValue
{
    if (!text) return;
    if (!picIDs.count)
    {
        [self update:text imageData:nil latitude:latValue longitude:longValue];
        return;
    }
    
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(updated:info:), @(WeiboCompositionTypeNewTweet));
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:text forKey:@"status"];
    if (latValue || longValue)
    {
        [params setObject:@(latValue) forKey:@"lat"];
        [params setObject:@(longValue) forKey:@"long"];
    }
    [params setObject:[picIDs componentsJoinedByString:@","] forKey:@"pic_id"];
    
    [self POST:@"statuses/upload_url_text.json" parameters:params callback:callback];
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
    WeiboCallback * callback = [self statusResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",sid],@"id", nil];
    NSString * url = @"statuses/destroy.json";
    [self POST:url parameters:params callback:callback];
}
- (void)destoryComment:(WeiboStatusID)sid{
    WeiboCallback * callback = [self commentResponseCallback];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",sid],@"cid", nil];
    NSString * url = @"comments/destroy.json";
    [self POST:url parameters:params callback:callback];
}
- (void)reply:(NSString *)text toStatusID:(WeiboStatusID)sid toCommentID:(WeiboStatusID)cid
{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeComment];
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(updated:info:), type);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             text, @"comment",
                             [NSString stringWithFormat:@"%lld",sid],@"id",
                             [NSString stringWithFormat:@"%lld",cid],@"cid",
                             @"1", @"without_mention", nil];
    NSString * url = @"comments/create.json";
    if (cid > 0) {
        url = @"comments/reply.json";
    }
    [self POST:url parameters:params multipartFormData:nil callback:callback];
}
- (void)updateWithComposition:(id<WeiboComposition>)composition
{
    if (composition.uploadImages.count > 1)
    {
        NSMutableArray * picIDs = [NSMutableArray array];
        
        for (WeiboUploadImage * uploadImage in composition.uploadImages)
        {
            if (uploadImage.pictureID.length)
            {
                [picIDs addObject:uploadImage.pictureID];
            }
        }
        
        [self update:composition.text imageIDs:picIDs latitude:composition.latitude longitude:composition.longitude];
    }
    else
    {
        [self update:composition.text imageData:[composition.uploadImages.firstObject imageData] latitude:composition.latitude longitude:composition.longitude];
    }
}

- (void)uploadImageWithData:(NSData *)imageData
{
    NSDictionary * params = [NSDictionary dictionaryWithObject:imageData forKey:@"pic"];
    
    [self POST:@"statuses/upload_pic.json" parameters:nil multipartFormData:params callback:responseCallback];
}

@end
