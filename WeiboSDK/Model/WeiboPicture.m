//
//  WeiboPicture.m
//  Weibo
//
//  Created by Wutian on 13-5-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboPicture.h"

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
        self.thumbnailImage = [dict stringForKey:@"thumbnail_pic"];
        self.middleImage = [dict stringForKey:@"bmiddle_pic"];
        self.originalImage = [dict stringForKey:@"original_pic"];
        
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
