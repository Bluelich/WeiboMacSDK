//
//  WeiboModel.h
//  Weibo
//
//  Created by Wutian on 14-3-11.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSDictionary+Accessors.h>
#import "WeiboCallback.h"

@class WeiboAccount;

@interface WeiboModel : NSObject <NSCoding>

@property (nonatomic, weak, readonly) WeiboAccount * account;
@property (nonatomic, assign, readonly) BOOL isMine;

+ (NSMutableArray *)ignoredCodingProperties;

- (instancetype)initWithAccount:(WeiboAccount *)account;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict account:(WeiboAccount *)account;
- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict;

+ (NSString *)defaultJSONArrayRootKey;
+ (NSString *)defaultJSONObjectRootKey;

+ (NSArray *)objectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account;
+ (NSArray *)objectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey;
+ (void)processObjects:(NSMutableArray *)objects withMetadata:(NSDictionary *)metadata;

+ (instancetype)objectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account;
+ (instancetype)objectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey;
+ (void)processObject:(WeiboModel *)object withMetadata:(NSDictionary *)metadata;

+ (void)parseObjectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account callback:(WeiboCallback *)callback;
+ (void)parseObjectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback;
+ (void)parseObjectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account callback:(WeiboCallback *)callback;
+ (void)parseObjectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback;

@end

@interface NSObject (WeiboModelMetaData)

- (NSDictionary *)weibo_serverMetaData;

@end
