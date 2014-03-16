//
//  WeiboEmotion.h
//  PopoverSampleApp
//
//  Created by Wu Tian on 12-7-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"

@class WeiboCallback;

@interface WeiboEmotion : WeiboModel

@property (nonatomic, strong) NSString * phrase;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, assign) BOOL hot;
@property (nonatomic, assign) BOOL common;
@property (nonatomic, strong) NSString * category;
@property (weak, nonatomic, readonly) NSString * fileName;

@end
