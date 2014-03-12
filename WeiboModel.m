//
//  WeiboModel.m
//  Weibo
//
//  Created by Wutian on 14-3-11.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboModel.h"
#import <objc/runtime.h>

static NSMutableDictionary *keyNames = nil;

@implementation WeiboModel

+ (void)initialize
{
	if (!keyNames)
	{
		keyNames = [[NSMutableDictionary alloc] init];
	}

	NSMutableArray *names = [[NSMutableArray alloc] init];
	NSMutableArray *nillableNames = [[NSMutableArray alloc] init];
	
	for (Class class = self; class != [WeiboModel class]; class = [class superclass])
	{
		unsigned int propertyCount;
		objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
		
		for (int i = 0; i < propertyCount; i++)
		{
			objc_property_t property = properties[i];
			NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
			[names addObject:name];
			
			[name release];
		}
		
		free(properties);
	}
    
    NSArray * ignored = [self ignoredCodingProperties];
    
    if (ignored)
    {
        [names removeObjectsInArray:ignored];
    }
	
	[keyNames setObject:names forKey:NSStringFromClass(self)];
	
	[names release];
	[nillableNames release];
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

@end
