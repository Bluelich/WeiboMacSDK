//
//  WeiboPicture.h
//  Weibo
//
//  Created by Wutian on 13-5-31.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"

@interface WeiboPicture : WeiboModel

@property (nonatomic, strong) NSString * thumbnailImage;
@property (nonatomic, strong) NSString * middleImage;
@property (nonatomic, strong) NSString * originalImage;

@end
