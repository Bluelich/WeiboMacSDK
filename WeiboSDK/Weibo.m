//
//  Weibo.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboAPI.h"
#import "WTCallback.h"

@implementation Weibo

static Weibo * _sharedWeibo = nil;

+ (Weibo *)sharedWeibo{
    if (!_sharedWeibo) {
        _sharedWeibo = [[[self class] alloc] init];
    }
    return _sharedWeibo;
}

- (id)init{
    if ((self = [super init])) {
        accounts = [[NSMutableArray alloc] init];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSData * accountData = [defaults dataForKey:@"accounts"];
        if (accountData) {
            NSArray * restoredAccounts = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
            if ([restoredAccounts isKindOfClass:[NSArray class]]) {
                for (WeiboAccount * account in restoredAccounts) {
                    if (![account isKindOfClass:[WeiboAccount class]]) {
                        continue;
                    }
                    if (account.oAuth2Token) {
                        [self addAccount:account];
                    }
                }
            }
        }
        heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:80.0 
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

- (void)dealloc{
    [heartbeatTimer invalidate];
    [cachePruningTimer invalidate];
    [accounts release];
    [super dealloc];
}

- (void)heartbeat:(id)sender{
    for (WeiboAccount * account in accounts) {
        [account refreshTimelines];
    }
}
- (void)pruneCaches:(id)sender{
    for (WeiboAccount * account in accounts) {
        //NSLog(@"pruning cache for : %@",[account username]);
        [account pruneUserCache];
        [account pruneStatusCache];
    }
}

- (void)shutdown{
    [heartbeatTimer invalidate];
    [cachePruningTimer invalidate];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * accountData = [NSKeyedArchiver archivedDataWithRootObject:[self accounts]];
    [defaults setObject:accountData forKey:@"accounts"];
}

- (NSArray *)accounts{
    return accounts;
}

- (void)signInWithUsername:(NSString *)aUsername 
                  password:(NSString *)aPassword 
                  callback:(WTCallback *)aCallback{
    WTCallback * callback = [WTCallback callbackWithTarget:self selector:@selector(didSignIn:info:) info:aCallback];
    WeiboAccount * account = [[WeiboAccount alloc] initWithUsername:aUsername password:aPassword];
    WeiboAPI * api = [WeiboAPI authenticatedRequestWithAPIRoot:account.apiRoot account:account callback:callback];
    [api xAuthRequestAccessTokens];
    [account autorelease];
}

- (void)didSignIn:(id)response info:(id)info{
    WeiboAccount * account = (WeiboAccount *)response;
    [self addAccount:account];
    [info invoke:account];
}

- (void)addAccount:(WeiboAccount *)aAccount{
    if ([aAccount isKindOfClass:[WeiboAccount class]]) {
        [accounts addObject:aAccount];
        [aAccount refreshTimelines];
    }
}

- (void)removeAccount:(WeiboAccount *)aAccount{
    [accounts removeObject:aAccount];
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
    [accounts removeObject:accounts];
    [accounts insertObject:accountToMove atIndex:toIndex];
    [accountToMove release];
}

- (void)refresh{
    
}

- (BOOL)hasFreshMessages{
    return NO;
}
- (BOOL)hasFreshAnythingApplicableToStatusItem{
    for (WeiboAccount * account in accounts) {
        if (account.hasFreshAnythingApplicableToStatusItem) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)hasFreshAnythingApplicableToDockBadge{
    for (WeiboAccount * account in accounts) {
        if (account.hasFreshAnythingApplicableToDockBadge) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)hasAnythingUnread{
    for (WeiboAccount * account in accounts) {
        if (account.hasAnythingUnread) {
            return YES;
        }
    }
    return NO;
}
@end
