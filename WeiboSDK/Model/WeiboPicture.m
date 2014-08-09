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
    _thumbnailImage = nil;
    _middleImage = nil;
    _originalImage = nil;
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict])
    {
        self.thumbnailImage = [dict weibo_stringForKey:@"thumbnail_pic" defaultValue:nil];
        self.middleImage = [dict weibo_stringForKey:@"bmiddle_pic" defaultValue:nil];
        self.originalImage = [dict weibo_stringForKey:@"original_pic" defaultValue:nil];
        
        if (!self.thumbnailImage.length) return NO;
        
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.thumbnailImage.hash;
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
