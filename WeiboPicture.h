//
//  WeiboPicture.h
//  Weibo
//
//  Created by Wutian on 13-5-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboPicture : NSObject

@property (nonatomic, retain) NSString * thumbnailImage;
@property (nonatomic, retain) NSString * middleImage;
@property (nonatomic, retain) NSString * originalImage;

+ (id)pictureWithDictionary:(NSDictionary *)dict;

@end
