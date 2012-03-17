//
//  LocalAutocompleteDB.m
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "LocalAutocompleteDB.h"
#import "WTFoundationUtilities.h"

static LocalAutocompleteDB * sharedDB = nil;

@implementation LocalAutocompleteDB
@synthesize db;

+ (void)verifyDatabase{
    WeiboUnimplementedMethod
}
+ (NSString *)databasePath{
    WeiboUnimplementedMethod
    return nil;
}
+ (LocalAutocompleteDB *)sharedAutocompleteDB{
    if (sharedDB) {
        sharedDB = [[[self class] alloc] init];
    }
    return sharedDB;
}
+ (void)resetDatabase{
    WeiboUnimplementedMethod
}
+ (void)shutdown{
    WeiboUnimplementedMethod
}

@end
