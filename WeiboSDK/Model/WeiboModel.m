//
//  WeiboModel.m
//  Weibo
//
//  Created by Wutian on 14-3-11.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboModel.h"
#import "NSObject+AssociatedObject.h"
#import "WeiboAccount.h"
#import <objc/runtime.h>
#import <libextobjc/extobjc.h>

@interface NSObject (WeiboModelSetMetaData)

- (void)weibo_setServerMetaData:(NSDictionary *)metaData;

@end

@interface WeiboModel ()

@property (nonatomic, weak) WeiboAccount * account;

@end

@implementation WeiboModel

static NSDictionary *keyNames = nil;

+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
	Class cls = self;
	BOOL stop = NO;
    
	while (!stop && ![cls isEqual:WeiboModel.class]) {
		unsigned count = 0;
		objc_property_t *properties = class_copyPropertyList(cls, &count);
        
		cls = cls.superclass;
		if (properties == NULL) continue;
        
		@onExit {
			free(properties);
		};
        
		for (unsigned i = 0; i < count; i++) {
			block(properties[i], &stop);
			if (stop) break;
		}
	}
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary * keyNamesMap = [NSMutableDictionary dictionaryWithDictionary:keyNames];
        
        NSMutableArray *names = [[NSMutableArray alloc] init];
        
        [self enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL * __attribute__((unused)) stop) {
            ext_propertyAttributes *attributes = ext_copyPropertyAttributes(property);
            @onExit {
                free(attributes);
            };
            
            if (attributes->readonly && attributes->ivar == NULL) return;
            
            NSString * key = @(property_getName(property));
            [names addObject:key];
        }];
        
        NSArray * ignored = [self ignoredCodingProperties];
        
        if (ignored)
        {
            [names removeObjectsInArray:ignored];
        }
        
        [keyNamesMap setObject:names forKey:NSStringFromClass(self)];
        
        keyNames = [NSDictionary dictionaryWithDictionary:keyNamesMap];
    });
}


+ (NSMutableArray *)ignoredCodingProperties
{
    return nil;
}

+ (NSArray *)codingProperties
{
	return [keyNames objectForKey:NSStringFromClass([self class])];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
	{
		for (NSString *name in [[self class] codingProperties])
		{
            id value = [decoder decodeObjectForKey:name];
            if (!value) continue;
			[self setValue:value forKey:name];
		}
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	for (NSString *name in [[self class] codingProperties])
	{
        id value = [self valueForKey:name];
        if (!value) continue;
		[encoder encodeObject:value forKey:name];
	}
}

#pragma mark - Accessors

- (BOOL)isMine
{
    return NO; // subclass can override
}

#pragma mark - JSON

- (instancetype)initWithAccount:(WeiboAccount *)account
{
    if (self = [self init])
    {
        self.account = account;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict account:(WeiboAccount *)account
{
    if (self = [self initWithAccount:account])
    {
        if (![self updateWithJSONDictionary:dict])
        {
            return nil;
        }
    }
    return self;
}
- (BOOL)updateWithJSONDictionary:(NSDictionary * __attribute__((unused)))dict
{
    return YES;
}

+ (NSString *)defaultJSONArrayRootKey
{
    return nil;
}
+ (NSString *)defaultJSONObjectRootKey
{
    return nil;
}

+ (NSArray *)objectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account
{
    return [self objectsWithJSONObject:jsonObject account:account rootKey:nil];
}
+ (NSArray *)objectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey
{
    if (!jsonObject) return nil;
    if (!rootKey) rootKey = [self defaultJSONArrayRootKey];
    
    NSArray * JSONArray = nil;
    NSMutableDictionary * metaData = nil;
    
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        JSONArray = jsonObject;
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSArray * allKeys = [jsonObject allKeys];
        
        if (rootKey && [allKeys containsObject:rootKey])
        {
            id rootObject = [jsonObject objectForKey:rootKey];
            
            if ([rootObject isKindOfClass:[NSArray class]])
            {
                JSONArray = rootObject;
            }
            else if (rootObject)
            {
                JSONArray = @[rootObject];
            }
            
            metaData = [jsonObject mutableCopy];
            [metaData removeObjectForKey:rootKey];
        }
        else
        {
            JSONArray = @[jsonObject];
        }
    }
    
    if (!JSONArray) return nil;
    
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSDictionary * dict in JSONArray)
    {
        WeiboModel * model = [[[self class] alloc] initWithJSONDictionary:dict account:account];
        
        if (model)
        {
            [result addObject:model];
        }
    }
    
    [self processObjects:result withMetadata:metaData];
    
    if (metaData)
    {
        [result weibo_setServerMetaData:metaData];
    }
    
    return result;
}

+ (void)processObjects:(NSMutableArray * __attribute__((unused)))objects withMetadata:(NSDictionary * __attribute__((unused)))metadata
{
    
}

+ (instancetype)objectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account
{
    return [self objectWithJSONObject:jsonObject account:account rootKey:[self defaultJSONObjectRootKey]];
}
+ (instancetype)objectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey
{
    if (!jsonObject) return nil;
    if (!rootKey) rootKey = [self defaultJSONObjectRootKey];
    
    NSDictionary * JSONDict = nil;
    NSMutableDictionary * metaData = nil;
    
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        JSONDict = [jsonObject firstObject];
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSArray * allKeys = [jsonObject allKeys];
        
        if (rootKey && [allKeys containsObject:rootKey])
        {
            id rootObject = [jsonObject objectForKey:rootKey];
            
            if ([rootObject isKindOfClass:[NSArray class]])
            {
                JSONDict = [rootObject firstObject];
            }
            else if ([rootObject isKindOfClass:[NSDictionary class]])
            {
                JSONDict = rootObject;
            }
            
            metaData = [jsonObject mutableCopy];
            [metaData removeObjectForKey:rootKey];
        }
        else
        {
            JSONDict = jsonObject;
        }
    }
    
    if (!JSONDict) return nil;
    
    WeiboModel * model = [[[self class] alloc] initWithJSONDictionary:JSONDict account:account];
    
    if (model)
    {
        [self processObject:model withMetadata:metaData];
        
        if (metaData)
        {
            [model weibo_setServerMetaData:metaData];
        }
    }
    
    return model;
}
+ (void)processObject:(WeiboModel * __attribute__((unused)))object withMetadata:(NSDictionary * __attribute__((unused)))metadata
{
    
}

+ (void)parseObjectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account callback:(WeiboCallback *)callback
{
    [self parseObjectsWithJSONObject:jsonObject account:account rootKey:nil callback:callback];
}
+ (void)parseObjectsWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * objects = [self objectsWithJSONObject:jsonObject account:account rootKey:rootKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [callback invoke:objects];
        });
    });
}

+ (void)parseObjectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account callback:(WeiboCallback *)callback
{
    [self parseObjectWithJSONObject:jsonObject account:account rootKey:nil callback:callback];
}
+ (void)parseObjectWithJSONObject:(id)jsonObject account:(WeiboAccount *)account rootKey:(NSString *)rootKey callback:(WeiboCallback *)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WeiboModel * object = [self objectWithJSONObject:jsonObject account:account rootKey:rootKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [callback invoke:object];
        });
    });
}

@end

static NSString * const WeiboModelMetadataKey = @"WeiboModelMetadataKey";

@implementation NSObject (WeiboModelSetMetaData)

- (void)weibo_setServerMetaData:(NSDictionary *)metaData
{
    [self weibo_setObject:metaData forAssociatedKey:WeiboModelMetadataKey retained:YES];
}

@end

@implementation NSObject (WeiboModelMetaData)

- (NSDictionary *)weibo_serverMetaData
{
    return [self weibo_objectWithAssociatedKey:WeiboModelMetadataKey];
}

@end

