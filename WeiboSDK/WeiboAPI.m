//
//  WeiboAPI.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAPI.h"
#import "WeiboAccount.h"
#import "WeiboComposition.h"
#import "WeiboRequestError.h"
#import "WeiboStatus.h"
#import "WeiboFavoriteStatus.h"
#import "WeiboComment.h"
#import "WeiboUser.h"
#import "WeiboUnread.h"
#import "WTCallback.h"
#import "WTHTTPRequest.h"
#import "OAuthConsumer.h"
#import "WTOASingnaturer.h"

#import "WTFoundationUtilities.h"
#import "SSKeychain.h"
#import "JSONKit.h"

@interface WeiboAPI()
- (void)_responseRecived:(id)responseValue callback:(WTCallback *)callback;
- (WTCallback *)errorlessCallbackWithCallback:(WTCallback *)callback;
- (WTCallback *)errorlessCallbackWithTarget:(id)target selector:(SEL)selector info:(id)info;
- (NSDictionary *)_queryStringToDictionary:(NSString *)string;
- (void)statusResponse:(id)response info:(id)info;
- (void)friendshipInfo:(id)response info:(id)info;
- (void)friendshipExists:(id)response info:(id)info;
- (void)directMessageResponse:(id)response info:(id)info;
- (void)directMessagesResponse:(id)response info:(id)info;
- (void)unreadCountResponse:(id)response info:(id)info;
- (void)resetUnreadResponse:(id)response info:(id)info;
- (void)xAuthMigrateResponse:(id)response info:(id)info;

@end

@implementation WeiboAPI

#pragma mark Object Lifecycle
+ (id)requestWithAPIRoot:(NSString *)root callback:(WTCallback *)callback{
    return [[[self alloc] initWithAccount:nil apiRoot:root callback:callback] autorelease];
}
+ (id)authenticatedRequestWithAPIRoot:(NSString *)root 
                              account:(WeiboAccount *)account 
                             callback:(WTCallback *)callback{
    return [[[self alloc] initWithAccount:account 
                                  apiRoot:root 
                                 callback:callback] autorelease];
}
- (id)initWithAccount:(WeiboAccount *)account
              apiRoot:(NSString *)root 
             callback:(WTCallback *)callback{
    if ((self = [super init])) {
        apiRoot = [root retain];
        authenticateWithAccount = [account retain];
        responseCallback = [callback retain];
    }
    return self;
}
- (void)dealloc{
    [apiRoot release]; apiRoot = nil;
    [authenticateWithAccount release]; authenticateWithAccount = nil;
    [responseCallback release]; responseCallback = nil;
    [super dealloc];
}

- (NSString *)keychainService{
    NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return identifier;
}


#pragma mark -
#pragma mark Request Core

- (void)request:(NSString *)partialUrl 
         method:(NSString *)method parameters:(NSDictionary *)parameters
multipartFormData:(NSDictionary *)parts
       callback:(WTCallback *)actualCallback
{
    WTCallback * callback = [self errorlessCallbackWithCallback:actualCallback];
    WTHTTPRequest * request = [self baseRequestWithPartialURL:partialUrl];
    [request setResponseCallback:callback];
    [request setRequestMethod:method];
    [request setParameters:parameters];
    for (NSString * key in parts) {
        [request addData:[parts objectForKey:key] forKey:key];
    }
    if (authenticateWithAccount.oAuth2Token || [method isEqualToString:@"POST"]) {
        [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
        [request startAuthrizedRequest];
    }else {
        [request startAsynchronous];
    }
}
- (void)v1_request:(NSString *)partialUrl 
         method:(NSString *)method parameters:(NSDictionary *)parameters
multipartFormData:(NSDictionary *)parts
       callback:(WTCallback *)actualCallback
{
    WTCallback * callback = [self errorlessCallbackWithCallback:actualCallback];
    WTHTTPRequest * request = [self v1_baseRequestWithPartialURL:partialUrl];
    [request setResponseCallback:callback];
    [request setRequestMethod:method];
    [request setParameters:parameters];
    for (NSString * key in parts) {
        [request addData:[parts objectForKey:key] forKey:key];
    }
    if (authenticateWithAccount.oAuthTokenSecret || [method isEqualToString:@"POST"]) {
        [request setOAuthToken:authenticateWithAccount.oAuthToken];
        [request setOAuthTokenSecret:authenticateWithAccount.oAuthTokenSecret];
        [request v1_startAuthrizedRequest];
    }else{
        [request startAsynchronous];
    }
}
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters multipartFormData:(NSDictionary *)parts callback:(WTCallback *)actualCallback{
    [self request:partialUrl method:@"POST" parameters:parameters multipartFormData:(NSDictionary *)parts callback:actualCallback];
}
- (void)POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self POST:partialUrl parameters:parameters multipartFormData:nil callback:actualCallback];
}
- (void)v1_POST:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self v1_request:partialUrl method:@"POST" parameters:parameters multipartFormData:nil callback:actualCallback];
}
- (void)GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self request:partialUrl method:@"GET" parameters:parameters multipartFormData:(NSDictionary *)nil callback:actualCallback];
}
- (void)v1_GET:(NSString *)partialUrl parameters:(NSDictionary *)parameters callback:(WTCallback *)actualCallback{
    [self v1_request:partialUrl method:@"GET" parameters:parameters multipartFormData:(NSDictionary *)nil callback:actualCallback];
}


- (WTHTTPRequest *)baseRequestWithPartialURL:(NSString *)partialUrl{
    return [WTHTTPRequest requestWithURL:[NSURL URLWithString:partialUrl 
                                                relativeToURL:[NSURL URLWithString:apiRoot]]];
}
- (WTHTTPRequest *)v1_baseRequestWithPartialURL:(NSString *)partialUrl{
    return [WTHTTPRequest requestWithURL:[NSURL URLWithString:partialUrl 
                                                relativeToURL:[NSURL URLWithString:WEIBO_APIROOT_V1]]];
}

#pragma mark Response Handling
- (void)handleRequestError:(WeiboRequestError *)error{
    LogIt([error description]);
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    if (error.code == WeiboErrorCodeTokenExpired) {
        authenticateWithAccount.tokenExpired = YES;
        [nc postNotificationName:kWeiboAccessTokenExpriedNotification object:authenticateWithAccount];
    }
}

- (void)_responseRecived:(id)responseValue callback:(WTCallback *)callback{
    if ([responseValue isKindOfClass:[WeiboRequestError class]]) {
        [self handleRequestError:responseValue];
        [callback dissociateTarget];
        [responseCallback invoke:responseValue];
    }else{
        [callback invoke:responseValue];
    }
}

- (WTCallback *)errorlessCallbackWithCallback:(WTCallback *)callback{
    return [WTCallback callbackWithTarget:self 
                                 selector:@selector(_responseRecived:callback:) 
                                     info:callback];
}
- (WTCallback *)errorlessCallbackWithTarget:(id)target selector:(SEL)selector info:(id)info{
    WTCallback * actualCallback = [WTCallback callbackWithTarget:target 
                                                        selector:selector 
                                                            info:nil];
    return [self errorlessCallbackWithCallback:actualCallback];
}



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
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params 
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count callback:(WTCallback *)callback{
    [self statusesRequest:url parameters:params sinceID:since maxID:max page:1 count:count callback:callback];
}
- (void)statusesRequest:(NSString *)url parameters:(NSDictionary *)params 
                sinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(statusResponse:info:), nil);
    [self statusesRequest:url parameters:params sinceID:since maxID:max count:count callback:callback];
}
- (void)statusResponse:(id)response info:(id)info{
    [WeiboStatus parseStatusesJSON:response callback:responseCallback];
}
- (void)commentsResponse:(id)response info:(id)info{
    BOOL fullText = info?![info boolValue]:YES;
    [WeiboComment setShouldMakeFullDisplayText:fullText];
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
#pragma mark -
#pragma mark Trends
- (void)trendStatusesWithTrend:(NSString *)keyword page:(NSUInteger)page count:(NSUInteger)count{
    WTCallback * callback = WTCallbackMake(self, @selector(statusResponse:info:), nil);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:keyword,@"q",nil];
    [self statusesRequest:@"search/topics.json" parameters:params sinceID:0 maxID:0 page:page count:count callback:callback];
}
- (void)trendsInHourly{
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(trendsResponse:info:) info:nil];
    [self GET:@"trends/hourly.json" parameters:nil callback:callback];
}
- (void)trendsResponse:(id)returnValue info:(id)info{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
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
#pragma mark Weibo Access
- (void)statuseResponse:(id)response info:(id)info{
    [responseCallback invoke:response];
}
- (void)commentResponse:(id)response info:(id)info{
    [responseCallback invoke:response];
}
- (WTCallback *)statuseResponseCallback{
    return WTCallbackMake(self, @selector(statuseResponse:info:), nil);
}
- (WTCallback *)commentResponseCallback{
    return WTCallbackMake(self, @selector(commentResponseCallback), nil);
}
- (void)repost:(NSString *)text repostingID:(WeiboStatusID)repostID shouldComment:(BOOL)comment{
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeStatus];
    WTCallback * callback = WTCallbackMake(self, @selector(updated:info:), type);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             text, @"status",
                             [NSString stringWithFormat:@"%lld",repostID], @"id", nil];
    NSString * url = @"statuses/repost.json";
    [self POST:url parameters:params callback:callback];
}

- (void)update:(NSString *)text inRetweetStatusID:(WeiboStatusID)reply imageData:(NSData *)image latitude:(double)latValue longitude:(double)longValue{
    if (reply > 0) {
        [self repost:text repostingID:reply shouldComment:NO];
        return;
    }
    NSNumber * type = [NSNumber numberWithInteger:WeiboCompositionTypeStatus];
    WTCallback * callback = WTCallbackMake(self, @selector(updated:info:), type);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             text, @"status",
                             [NSString stringWithFormat:@"%f",latValue], @"lat",
                             [NSString stringWithFormat:@"%f",longValue], @"long", nil];
    NSDictionary * parts = nil;
    NSString * url = @"statuses/update.json";
    if (image && reply == 0) {
        parts = [NSDictionary dictionaryWithObject:image forKey:@"pic"];
        url = @"statuses/upload.json";
    }
    [self POST:url parameters:params multipartFormData:parts callback:callback];
}
- (void)update:(NSString *)text inRetweetStatusID:(WeiboStatusID)reply{
    [self update:text inRetweetStatusID:reply imageData:nil latitude:0 longitude:0];
}
- (void)updated:(id)response info:(id)info{
    WeiboCompositionType type = [info integerValue];
    [authenticateWithAccount refreshTimelineForType:type];
    [responseCallback invoke:response];
}
- (void)destoryStatus:(WeiboStatusID)sid{
    WTCallback * callback = [self statuseResponseCallback];
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
- (void)reply:(NSString *)text toStatusID:(WeiboStatusID)sid toCommentID:(WeiboStatusID)cid{
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
- (void)updateWithComposition:(WeiboComposition *)composition{
    if (composition.replyToStatus) {
        WeiboStatusID toSID = composition.replyToStatus.sid, toCID = 0;
        if ([composition.replyToStatus isKindOfClass:[WeiboComment class]]) {
            WeiboComment * comment = (WeiboComment *)composition.replyToStatus;
            toCID = toSID;
            toSID = comment.replyToStatus.sid;
        }
        [self reply:composition.text toStatusID:toSID toCommentID:toCID];
    }else {
        [self update:composition.text inRetweetStatusID:composition.retweetingStatusID imageData:composition.imageData latitude:0 longitude:0];
    }
}

#pragma mark -
#pragma mark User Access
- (void)verifyCredentials{
    WTCallback * callback = WTCallbackMake(self, @selector(myUserIDResponse:info:), nil);
    [self GET:@"account/get_uid.json" parameters:nil callback:callback];
}
- (void)myUserIDResponse:(id)returnValue info:(id)info{
    if ([returnValue isKindOfClass:[WeiboRequestError class]]) {
        return;
    }
    authenticateWithAccount.tokenExpired = NO;
    NSString * userID = [[[returnValue objectFromJSONString] objectForKey:@"uid"] stringValue];
    WTCallback * callback = WTCallbackMake(self, @selector(verifyCredentialsResponse:info:), nil);
    NSDictionary * params = [NSDictionary dictionaryWithObject:userID forKey:@"uid"];
    [self GET:@"users/show.json" parameters:params callback:callback];
}
- (void)verifyCredentialsResponse:(id)response info:(id)info{
    [WeiboUser parseUserJSON:response onComplete:^(id object) {
        [responseCallback invoke:object];
    }];
}
- (void)userWithID:(WeiboUserID)uid{
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",uid] 
                                        forKey:@"user_id"];
    WTCallback * callback = [self userResponseCallback];
    [self GET:@"users/show.json" parameters:param callback:callback];
}
- (void)userWithUsername:(NSString *)screenname{
    NSDictionary * param = [NSDictionary dictionaryWithObject:screenname 
                                        forKey:@"screen_name"];
    WTCallback * callback = [self userResponseCallback];
    [self GET:@"users/show.json" parameters:param callback:callback];
}
#pragma mark ( User Response Handling )
- (void)userResponse:(id)response info:(id)info{
    [WeiboUser parseUserJSON:response onComplete:^(id object) {
        [responseCallback invoke:object];
    }];
}
- (WTCallback *)userResponseCallback{
    return WTCallbackMake(self, @selector(userResponse:info:), nil);
}
#pragma mark -
#pragma mark Relationship
- (void)followUserID:(WeiboUserID)uid{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",uid],@"uid", nil];
    [self POST:@"friendships/create.json" parameters:params callback:[self userResponseCallback]];
}
- (void)followUsername:(NSString *)screenname{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             screenname,@"screen_name", nil];
    [self POST:@"friendships/create.json" parameters:params callback:[self userResponseCallback]];
}
- (void)unfollowUserID:(WeiboUserID)uid{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",uid],@"uid", nil];
    [self POST:@"friendships/destroy.json" parameters:params callback:[self userResponseCallback]];
}
- (void)unfollowUsername:(NSString *)screenname{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             screenname,@"screen_name", nil];
    [self POST:@"friendships/destroy.json" parameters:params callback:[self userResponseCallback]];
}
- (WTCallback *)friendshipExistsCallback{
    return WTCallbackMake(self, @selector(friendshipExists:info:), nil);
}
- (WTCallback *)friendshipInfoCallback{
    return WTCallbackMake(self, @selector(friendshipInfo:info:), nil);
}
- (void)lookupRelationships:(WeiboUserID)tuid{
    [self userID:authenticateWithAccount.user.userID followsUserID:tuid];
}
- (void)userID:(WeiboUserID)suid followsUserID:(WeiboUserID)tuid{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",suid],@"user_a",
                             [NSString stringWithFormat:@"%lld",tuid],@"user_b", nil];
    [self GET:@"friendships/exists.json" parameters:params callback:[self friendshipExistsCallback]];
}
- (void)friendshipForSourceUserID:(WeiboUserID)suid targetUserID:(WeiboUserID)tuid{
    WeiboUnimplementedMethod
}
- (void)friendshipForSourceUsername:(NSString *)sscreenname targetUsername:(NSString *)tscreenname{
    WeiboUnimplementedMethod
}
- (void)friendshipInfo:(id)response info:(id)info{
    WeiboUnimplementedMethod
}
- (void)friendshipExists:(id)response info:(id)info{
    NSDictionary * result = [response objectFromJSONString];
    [responseCallback invoke:[result objectForKey:@"friends"]];
}
#pragma mark -
#pragma mark Direct Message
- (WTCallback *)directMessageResponseCallback{
    return WTCallbackMake(self, @selector(directMessageResponse:info:), nil);
}
- (WTCallback *)directMessagesResponseCallback{
    return WTCallbackMake(self, @selector(directMessagesResponse:info:), nil);
}
- (void)directMessagesSinceID:(WeiboStatusID)since maxID:(WeiboStatusID)max count:(NSUInteger)count{
    [self statusesRequest:@"direct_messages.json" parameters:nil sinceID:since maxID:max 
                    count:count callback:[self directMessagesResponseCallback]];
}
- (void)directMessageResponse:(id)response info:(id)info{
    [responseCallback dissociateTarget];
    WeiboUnimplementedMethod
    // need sufficient app permission
}
- (void)directMessagesResponse:(id)response info:(id)info{
    [responseCallback dissociateTarget];
    WeiboUnimplementedMethod
    // need sufficient app permission
}
#pragma mark -
#pragma mark Other
- (void)unreadCountSinceID:(WeiboStatusID)since{
    WTCallback * callback = WTCallbackMake(self, @selector(unreadCountResponse:info:), nil);
    NSDictionary * param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",authenticateWithAccount.user.userID] forKey:@"uid"];
    
    NSURL * url = [NSURL URLWithString:@"https://rm.api.weibo.com/2/remind/unread_count.json"];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"GET"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startAuthrizedRequest];
}
- (void)unreadCount{
    [self unreadCountSinceID:0];
}
- (void)unreadCountResponse:(id)response info:(id)info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        NSLog(@"response:%@",response);
        [responseCallback dissociateTarget];
        return;
    }
    [WeiboUnread parseUnreadJSON:response onComplete:^(id object) {
        [responseCallback invoke:object];
    }];
}
- (void)v1_resetUnreadWithType:(WeiboUnreadCountType)type{
    WTCallback * callback = WTCallbackMake(self, @selector(resetUnreadResponse:info:), nil);
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",type] 
                                        forKey:@"type"];
    [self v1_POST:@"statuses/reset_count.json" parameters:param callback:callback];
}
- (void)resetUnreadWithType:(WeiboUnreadCountType)type{
    WTCallback * callback = WTCallbackMake(self, @selector(resetUnreadResponse:info:), nil);
    NSString * typeString = nil;
    switch (type) {
        case WeiboUnreadCountTypeStatus:
            typeString = @"status";
            break;
        case WeiboUnreadCountTypeFollower:
            typeString = @"follower";
            break;
        case WeiboUnreadCountTypeComment:
            typeString = @"cmt";
            break;
        case WeiboUnreadCountTypeDirectMessage:
            typeString = @"dm";
            break;
        case WeiboUnreadCountTypeMention:
            typeString = @"mention_status";
            break;
        default:{
            [callback dissociateTarget];
            return;
        }
    }
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:typeString forKey:@"type"];
    NSURL * url = [NSURL URLWithString:@"https://rm.api.weibo.com/2/remind/set_count.json"];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"POST"];
    [request setParameters:param];
    [request setOAuth2Token:authenticateWithAccount.oAuth2Token];
    [request startAuthrizedRequest];
}
- (void)resetUnreadResponse:(id)response info:(id)info{
    // Not Implemented Yet.
    [responseCallback dissociateTarget];
}

#pragma mark -
#pragma mark oAuth (xAuth)
- (void)clientAuthRequestAccessToken{
    WTCallback * callback = [self errorlessCallbackWithTarget:self selector:@selector(clientAuthResponse:info:) info:nil];
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:WEIBO_CONSUMER_KEY,@"client_id",WEIBO_CONSUMER_SECRET,@"client_secret",[authenticateWithAccount.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"username",authenticateWithAccount.password,@"password",@"password",@"grant_type", nil];
    
    NSURL * url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    WTHTTPRequest * request = [WTHTTPRequest requestWithURL:url];
    [request setResponseCallback:callback];
    [request setRequestMethod:@"POST"];
    [request setParameters:params];
    [request startAuthrizedRequest];
}
- (void)clientAuthResponse:(id)returnValue info:(id)info{
    [self oAuth2TokenResponse:returnValue info:info];
}
- (void)xAuthRequestAccessTokens{
    WTCallback * callback = [self errorlessCallbackWithTarget:self 
                                                     selector:@selector(xAuthMigrateResponse:info:) 
                                                         info:nil];

     NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
     authenticateWithAccount.username,@"x_auth_username",
     authenticateWithAccount.password,@"x_auth_password",
     @"client_auth",@"x_auth_mode", nil];
     [self v1_POST:@"oauth/access_token" parameters:parameters callback:callback];
}

- (void)xAuthMigrateResponse:(id)returnValue info:(id)info{
    NSDictionary * resultDictionary = [self _queryStringToDictionary:returnValue];
    NSString * token = [resultDictionary valueForKey:@"oauth_token"];
    NSString * tokenSecret = [resultDictionary valueForKey:@"oauth_token_secret"];
    [authenticateWithAccount setOAuthToken:token];
    [authenticateWithAccount setOAuthTokenSecret:tokenSecret];
    [self oAuth2RequestTokenByAccessToken];
}
- (void)oAuth2RequestTokenByAccessToken{
    WTCallback * callback = [self errorlessCallbackWithTarget:self 
                                                     selector:@selector(oAuth2TokenResponse:info:) 
                                                         info:nil];
    [self v1_POST:@"oauth2/get_oauth2_token" parameters:nil callback:callback];
}
- (void)oAuth2TokenResponse:(id)returnValue info:(id)info{
    NSString * tokenResponse = returnValue;
    NSDictionary * dic = [tokenResponse objectFromJSONString];
    NSLog(@"%@",dic);
    NSString * token = [dic valueForKey:@"access_token"];
    NSTimeInterval expiresIn = [[dic valueForKey:@"expires_in"] intValue];
    [authenticateWithAccount setOAuth2Token:token];
    [authenticateWithAccount setExpireTime:expiresIn];
    [SSKeychain setPassword:token forService:[self keychainService] account:authenticateWithAccount.username];
    [authenticateWithAccount verifyCredentials:responseCallback];
}

- (NSDictionary *)_queryStringToDictionary:(NSString *)string{
    NSArray * components = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];
    for (NSString * component in components) {
        if ([component length] == 0) continue;
        NSArray * keyAndValue = [component componentsSeparatedByString:@"="];
        if ([keyAndValue count] < 2) continue;
        NSString * value = [keyAndValue objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        [resultDictionary setValue:value forKey:[keyAndValue objectAtIndex:0]];
    }
    return resultDictionary;
}

@end
