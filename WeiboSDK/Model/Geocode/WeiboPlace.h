//
//  WeiboPlace.h
//  Weibo
//
//  Created by Wutian on 14/9/29.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboModel.h"
#import <CoreLocation/CoreLocation.h>

@interface WeiboPlace : WeiboModel

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString * cityName;
@property (nonatomic, copy) NSString * provinceName;
@property (nonatomic, copy) NSString * address;

@property (nonatomic, readonly) BOOL coordinateValid;

@end
