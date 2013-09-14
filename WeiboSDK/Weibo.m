//
//  Weibo.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboAccount+Filters.h"
#import "WeiboAccount+Superpower.h"
#import "WeiboAPI+AccountMethods.h"
#import "WeiboAPI+UserMethods.h"
#import "WTCallback.h"
#import "SSKeychain.h"

NSString * const WeiboAccountSetDidChangeNotification = @"WeiboAccountSetDidChangeNotification";

NSString * const WeiboObjectWithIdentifierWillDeallocNotification = @"WeiboObjectWithIdentifierWillDeallocNotification";
NSString * const WeiboObjectUserInfoUniqueIdentifierKey = @"WeiboObjectUserInfoUniqueIdentifierKey";
NSString * const WeiboDidHeartbeatNotification = @"WeiboDidHeartbeatNotification";


@implementation Weibo

static Weibo * _sharedWeibo = nil;

+ (Weibo *)sharedWeibo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeibo = [[[self class] alloc] init];
        [_sharedWeibo restoreAccounts];
    });
    return _sharedWeibo;
}

- (id)init
{
    if ((self = [super init])) {
        accounts = [[NSMutableArray alloc] init];
        
        heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                 target:self
                                               selector:@selector(heartbeat:) 
                                               userInfo:nil 
                                                repeats:YES];
        [heartbeatTimer fire];
        cachePruningTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                             target:self 
                                                           selector:@selector(pruneCaches:) 
                                                           userInfo:nil 
                                                            repeats:YES];
        [cachePruningTimer fire];
    }
    return self;
}

- (void)restoreAccounts
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * accountData = [defaults dataForKey:@"accounts"];
    BOOL hasAccountRestored = NO;
    if (accountData) {
        NSArray * restoredAccounts = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
        if ([restoredAccounts isKindOfClass:[NSArray class]]) {
            for (WeiboAccount * account in restoredAccounts) {
                if (![account isKindOfClass:[WeiboAccount class]]) {
                    continue;
                }
                if (account.oAuth2Token) {
                    [self addAccount:account postsNotification:NO];
                    
                    [account didRestoreFromDisk];
                    
                    hasAccountRestored = YES;
                }
            }
        }
    }
    
    if (hasAccountRestored)
    {
        // Post notification ?
    }
}

- (void)dealloc{
    [heartbeatTimer invalidate];
    [cachePruningTimer invalidate];
    [accounts release];
    [super dealloc];
}

- (void)heartbeat:(id)sender
{
    for (WeiboAccount * account in accounts)
    {
        if (!account.tokenExpired)
        {
            [account refreshTimelines];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboDidHeartbeatNotification object:nil];
}
- (void)pruneCaches:(id)sender
{
    for (WeiboAccount * account in accounts)
    {
        [account pruneUserCache];
        [account pruneStatusCache];
        [account pruneFilters];
    }
}

- (void)shutdown
{
    [heartbeatTimer invalidate];
    [cachePruningTimer invalidate];
    
    [[self accounts] makeObjectsPerformSelector:@selector(willSaveToDisk)];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * accountData = [NSKeyedArchiver archivedDataWithRootObject:[self accounts]];
    [defaults setObject:accountData forKey:@"accounts"];
    [defaults synchronize];
}

- (NSArray *)accounts
{
    return accounts;
}

- (void)signInWithUsername:(NSString *)aUsername 
                  password:(NSString *)aPassword 
                  callback:(WTCallback *)aCallback
{
    WTCallback * callback = [WTCallback callbackWithTarget:self selector:@selector(didSignIn:info:) info:aCallback];
    WeiboAccount * account = [[WeiboAccount alloc] initWithUsername:aUsername password:aPassword];
    WeiboAPI * api = [WeiboAPI authenticatedRequestWithAPIRoot:account.apiRoot account:account callback:callback];
    [api clientAuthRequestAccessToken];
    [account autorelease];
}
- (void)didSignIn:(id)response info:(id)info
{
    WeiboAccount * account = (WeiboAccount *)response;
    [self addAccount:account];
    [info invoke:account];
}

#define kWeiboAccessTokenVerifingAccountKey @"kWeiboAccessTokenVerifingAccountKey"
#define kWeiboAccessTokenVerifingCallbackKey @"kWeiboAccessTokenVerifingCallbackKey"
- (void)signInWithAccessToken:(NSString *)accessToken tokenExpire:(NSTimeInterval)expireTime userID:(WeiboUserID)userID callback:(WTCallback *)aCallback
{
    WeiboAccount * account = [[[WeiboAccount alloc] initWithUserID:userID oAuth2Token:accessToken] autorelease];
    
    account.expireTime = expireTime;
    
    NSDictionary * info = @{kWeiboAccessTokenVerifingAccountKey: account,
                            kWeiboAccessTokenVerifingCallbackKey: aCallback};
    
    WTCallback * callback = WTCallbackMake(self, @selector(accessTokenVerifingResponse:info:), info);
    WeiboAPI * api = [account authenticatedRequest:callback];
    
    [api verifyCredentials];
}
- (void)accessTokenVerifingResponse:(id)response info:(id)info
{
    WeiboAccount * account = info[kWeiboAccessTokenVerifingAccountKey];
    WTCallback * callback = info[kWeiboAccessTokenVerifingCallbackKey];
    
    id callbackObject = account;
    
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        callbackObject = response;
    }
    else if ([response isKindOfClass:[WeiboUser class]])
    {
        WeiboUser * newUser = (WeiboUser *)response;
        
        if (account.user.userID && ![newUser isEqual:account.user])
        {
            WeiboRequestError * error = [WeiboRequestError errorWithResponseString:@"" statusCode:WeiboErrorCodeTokenInvalid];
            callbackObject = error;
        }
        else
        {
            [account setUser:newUser];
            [account myUserDidUpdate:newUser];
            
            NSInteger existIndex = [self.accounts indexOfObject:account];
            
            if (existIndex != NSNotFound)
            {
                // account exist, update it.
                
                [[account retain] autorelease];
                [self.accounts removeObjectAtIndex:existIndex];
                [self.accounts insertObject:account atIndex:existIndex];
            }
            else
            {
                // account not exist, add it to our set.
                [self addAccount:account];
            }
            
            [SSKeychain setPassword:account.oAuth2Token forService:[account keychainService] account:[WeiboAccount keyChainAccountForUserID:account.user.userID]];
        }
    }
    
    [callback invoke:callbackObject];
}

- (void)refreshTokenForAccount:(WeiboAccount *)aAccount 
                      password:(NSString *)aPassword 
                      callback:(WTCallback *)aCallback
{
    WTCallback * callback = WTCallbackMake(self, @selector(didRefresh:info:), aCallback);
    aAccount.password = aPassword;
    WeiboAPI * api = [WeiboAPI authenticatedRequestWithAPIRoot:aAccount.apiRoot account:aAccount callback:callback];
    [api clientAuthRequestAccessToken];
}
- (void)didRefresh:(id)response info:(id)info
{
    WeiboAccount * account = (WeiboAccount *)response;
    [info invoke:account];
}

- (void)addAccount:(WeiboAccount *)aAccount postsNotification:(BOOL)post
{
    if ([aAccount isKindOfClass:[WeiboAccount class]])
    {
        [accounts addObject:aAccount];
        [aAccount refreshTimelines];
        
        if (post)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSetDidChangeNotification object:self];
        }
    }
}

- (void)addAccount:(WeiboAccount *)aAccount
{
    [self addAccount:aAccount postsNotification:YES];
}

- (void)removeAccount:(WeiboAccount *)aAccount
{
    [aAccount updateSuperpowerTokenToKeychain:nil];
    [accounts removeObject:aAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSetDidChangeNotification
                                                        object:self];
}

- (BOOL)containsAccount:(WeiboAccount *)aAccount{
    for (WeiboAccount * account in accounts) {
        if ([account isEqualToAccount:aAccount]) {
            return YES;
        }
    }
    return NO;
}

- (WeiboAccount *)accountWithUsername:(NSString *)aUsername{
    for (WeiboAccount * account in accounts) {
        if ([account.username isEqualToString:aUsername]) {
            return account;
        }
    }
    return nil;
}
- (WeiboAccount *)accountWithUserID:(WeiboUserID)userID
{
    for (WeiboAccount * account in accounts)
    {
        if (account.user.userID == userID)
        {
            return account;
        }
    }
    return nil;
}

- (WeiboAccount *)defaultAccount{
    if ([accounts count] < 1) {
        return nil;
    }
    return [accounts objectAtIndex:0];
}

- (void)reorderAccountFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    if (fromIndex >= [accounts count] || toIndex >= [accounts count]) {
        return;
    }
    WeiboAccount * accountToMove = [[accounts objectAtIndex:fromIndex] retain];
    [accounts removeObject:accountToMove];
    [accounts insertObject:accountToMove atIndex:toIndex];
    [accountToMove release];
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboAccountSetDidChangeNotification object:nil];
}

- (void)refresh{
    
}

- (BOOL)hasFreshMessages
{
    return NO;
}
- (BOOL)hasFreshAnythingApplicableToStatusItem
{
    for (WeiboAccount * account in accounts) {
        if (account.hasFreshAnythingApplicableToStatusItem) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)hasFreshAnythingApplicableToDockBadge
{
    for (WeiboAccount * account in accounts) {
        if (account.hasFreshAnythingApplicableToDockBadge) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)hasAnythingUnread
{
    for (WeiboAccount * account in accounts) {
        if (account.hasAnythingUnread) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)unreadCountForDockBadge
{
    NSInteger count = 0;
    for (WeiboAccount * account in accounts)
    {
        count += account.unreadCountForDockBadge;
    }
    return count;
}

@end
