//
//  WeiboAPI+UserMethods.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboAPI+Private.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboUser.h"

@implementation WeiboAPI (UserMethods)

#pragma mark -
#pragma mark User Access

- (void)verifyCredentials
{
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(myUserIDResponse:info:), nil);
    [self GET:@"account/get_uid.json" parameters:nil callback:callback];
}
- (void)myUserIDResponse:(id)returnValue info:(id)info
{
    if ([returnValue isKindOfClass:[WeiboRequestError class]]) {
        return;
    }
    authenticateWithAccount.tokenExpired = NO;
    NSString * userID = [[returnValue objectForKey:@"uid"] stringValue];
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(verifyCredentialsResponse:info:), nil);
    NSDictionary * params = [NSDictionary dictionaryWithObject:userID forKey:@"uid"];
    [self GET:@"users/show.json" parameters:params callback:callback];
}
- (void)verifyCredentialsResponse:(id)response info:(id)info
{
    [WeiboUser parseObjectWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}
- (void)userWithID:(WeiboUserID)uid
{
    NSDictionary * param;
    param = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld",uid]
                                        forKey:@"user_id"];
    WeiboCallback * callback = [self userResponseCallback];
    [self GET:@"users/show.json" parameters:param callback:callback];
}
- (void)userWithUsername:(NSString *)screenname
{
    NSDictionary * param = [NSDictionary dictionaryWithObject:screenname
                                                       forKey:@"screen_name"];
    WeiboCallback * callback = [self userResponseCallback];
    [self GET:@"users/show.json" parameters:param callback:callback];
}

- (void)updateRemark:(NSString *)remark forUserID:(WeiboUserID)uid
{
    if (!remark) remark = @"";
    
    NSDictionary * params = @{@"uid":@(uid), @"remark":remark};
    
    [self POST:@"friendships/remark/update.json" parameters:params callback:[self userResponseCallback]];
}

#pragma mark ( User Response Handling )
- (void)userResponse:(id)response info:(id)info
{
    [WeiboUser parseObjectWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}
- (WeiboCallback *)userResponseCallback
{
    return WeiboCallbackMake(self, @selector(userResponse:info:), nil);
}

- (void)followUserID:(WeiboUserID)uid
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",uid],@"uid", nil];
    [self POST:@"friendships/create.json" parameters:params callback:[self userResponseCallback]];
}
- (void)followUsername:(NSString *)screenname
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             screenname,@"screen_name", nil];
    [self POST:@"friendships/create.json" parameters:params callback:[self userResponseCallback]];
}
- (void)unfollowUserID:(WeiboUserID)uid
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",uid],@"uid", nil];
    [self POST:@"friendships/destroy.json" parameters:params callback:[self userResponseCallback]];
}
- (void)unfollowUsername:(NSString *)screenname
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             screenname,@"screen_name", nil];
    [self POST:@"friendships/destroy.json" parameters:params callback:[self userResponseCallback]];
}
- (WeiboCallback *)friendshipExistsCallback
{
    return WeiboCallbackMake(self, @selector(friendshipExists:info:), nil);
}
- (WeiboCallback *)friendshipInfoCallback
{
    return WeiboCallbackMake(self, @selector(friendshipInfo:info:), nil);
}
- (void)lookupRelationships:(WeiboUserID)tuid
{
    [self userID:authenticateWithAccount.user.userID followsUserID:tuid];
}
- (void)userID:(WeiboUserID)suid followsUserID:(WeiboUserID)tuid
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld",suid],@"source_id",
                             [NSString stringWithFormat:@"%lld",tuid],@"target_id", nil];
    [self GET:@"friendships/show.json" parameters:params callback:[self friendshipExistsCallback]];
}
- (void)friendshipForSourceUserID:(WeiboUserID)suid targetUserID:(WeiboUserID)tuid
{
    WeiboUnimplementedMethod
}
- (void)friendshipForSourceUsername:(NSString *)sscreenname targetUsername:(NSString *)tscreenname
{
    WeiboUnimplementedMethod
}
- (void)friendshipInfo:(id)response info:(id)info
{
    WeiboUnimplementedMethod
}
- (void)friendshipExists:(id)response info:(id)info
{
    [responseCallback invoke:[response objectForKey:@"target"]];
}

#pragma mark - User Lists

- (void)userlistResponse:(id)response info:(id)info
{
    [WeiboUser parseObjectsWithJSONObject:response account:authenticateWithAccount callback:responseCallback];
}

- (WeiboCallback *)userlistResponseCallback
{
    return [self userlistCallbackWithCursor:0];
}
- (WeiboCallback *)userlistCallbackWithCursor:(WeiboUserID)cursor
{
    return WeiboCallbackMake(self, @selector(userlistResponse:info:), nil);
}

- (void)followersForUsername:(NSString *)screenname cursor:(WeiboUserID)cursor
{
    NSDictionary * params = @{@"screen_name":screenname,
                              @"cursor":@(cursor),
                              @"count":@"200"};
    [self GET:@"friendships/followers.json" parameters:params callback:[self userlistCallbackWithCursor:cursor]];
}
- (void)followersForUserID:(WeiboUserID)userid cursor:(WeiboUserID)cursor
{
    NSDictionary * params = @{@"uid":@(userid),
                              @"cursor":@(cursor),
                              @"count":@"200"};
    [self GET:@"friendships/followers.json" parameters:params callback:[self userlistCallbackWithCursor:cursor]];
}
- (void)friendsForUsername:(NSString *)screenname cursor:(WeiboUserID)cursor
{
    NSDictionary * params = @{@"screen_name":screenname,
                              @"cursor":@(cursor),
                              @"count":@"200"};
    [self GET:@"friendships/friends.json" parameters:params callback:[self userlistCallbackWithCursor:cursor]];
}
- (void)friendsForUserID:(WeiboUserID)userid cursor:(WeiboUserID)cursor
{
    NSDictionary * params = @{@"uid":@(userid),
                              @"cursor":@(cursor),
                              @"count":@"200"};
    [self GET:@"friendships/friends.json" parameters:params callback:[self userlistCallbackWithCursor:cursor]];
}
- (void)bilateralFriendsForUserID:(WeiboUserID)userID count:(NSInteger)count page:(NSInteger)page
{
    count = BETWEEN(0, count, 200);
    page  = MAX(1, page);
    NSDictionary * params = @{@"uid": @(userID), @"count": @(count), @"page": @(page)};
    
    [self GET:@"friendships/friends/bilateral.json" parameters:params callback:[self userlistResponseCallback]];
}

- (void)usersWithKeyword:(NSString *)keyword page:(NSInteger)page
{
    NSDictionary * params = @{@"q":keyword, @"page": @(page), @"count": @20};
    
    [self GET:@"search/users.json" parameters:params callback:[self userlistResponseCallback]];
}

- (void)userMentionSuggestionsResponse:(id)response info:(id)info
{
    NSString * keyword = nil;
    if ([info isKindOfClass:[NSDictionary class]])
    {
        keyword = [info objectForKey:@"keyword"];
    }
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    if (keyword)
    {
        [result setObject:keyword forKey:@"keyword"];
    }
    if (response)
    {
        [result setObject:response forKey:@"response"];
    }

    [responseCallback invoke:result];
}
- (void)userMentionSuggestionsWithKeyword:(NSString *)keyword
{
    if (!keyword) keyword = @"";
    NSDictionary * params = @{@"q": keyword, @"type": @"0"};
    
    [self GET:@"search/suggestions/at_users.json" parameters:params callback:WeiboCallbackMake(self, @selector(userMentionSuggestionsResponse:info:), @{@"keyword": keyword})];
}

@end
