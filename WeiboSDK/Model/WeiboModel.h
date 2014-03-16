//
//  WeiboModel.h
//  Weibo
//
//  Created by Wutian on 14-3-11.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboCallback.h"

@interface WeiboModel : NSObject <NSCoding>

+ (NSMutableArray *)ignoredCodingProperties;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;
- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict;

+ (NSString *)defaultJSONArrayRootKey;
+ (NSString *)defaultJSONObjectRootKey;

+ (NSArray *)objectsWithJSONObject:(id)jsonObject;
+ (NSArray *)objectsWithJSONObject:(id)jsonObject rootKey:(NSString *)rootKey;
+ (void)processObjects:(NSMutableArray *)objects withMetadata:(NSDictionary *)metadata;

+ (instancetype)objectWithJSONObject:(id)jsonObject;
+ (instancetype)objectWithJSONObject:(id)jsonObject rootKey:(NSString *)rootKey;
+ (void)processObject:(WeiboModel *)object withMetadata:(NSDictionary *)metadata;

+ (void)parseObjectsWithJSONObject:(id)jsonObject callback:(WeiboCallback *)callback;
+ (void)parseObjectsWithJSONObject:(id)jsonObject rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback;
+ (void)parseObjectWithJSONObject:(id)jsonObject callback:(WeiboCallback *)callback;
+ (void)parseObjectWithJSONObject:(id)jsonObject rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback;

@end

@interface NSObject (WeiboModelMetaData)

- (NSDictionary *)weibo_serverMetaData;

@end