//
//  WeiboPicture.m
//  Weibo
//
//  Created by Wutian on 13-5-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboPicture.h"
#import "NSDictionary+WeiboAdditions.h"

@implementation WeiboPicture

- (void)dealloc
{
    [_thumbnailImage release], _thumbnailImage = nil;
    [_middleImage release], _middleImage = nil;
    [_originalImage release], _originalImage = nil;
    [super dealloc];
}

+ (id)pictureWithDictionary:(NSDictionary *)dict
{
    if (![dict objectForKey:@"thumbnail_pic"])
    {
        return nil;
    }
    
    return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.thumbnailImage = [dict stringForKey:@"thumbnail_pic" defaultValue:nil];
        self.middleImage = [dict stringForKey:@"bmiddle_pic" defaultValue:nil];
        self.originalImage = [dict stringForKey:@"original_pic" defaultValue:nil];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (![object isKindOfClass:[WeiboPicture class]])
    {
        return NO;
    }
    
    return [self.thumbnailImage isEqual:[object thumbnailImage]];
}

- (NSString *)middleImage
{
    if (!_middleImage)
    {
        return [self.thumbnailImage stringByReplacingOccurrencesOfString:@"/thumbnail/" withString:@"/bmiddle/"];
    }
    return _middleImage;
}

- (NSString *)originalImage
{
    if (!_originalImage)
    {
        return [self.thumbnailImage stringByReplacingOccurrencesOfString:@"/thumbnail/" withString:@"/large/"];
    }
    return _originalImage;
}

@end
