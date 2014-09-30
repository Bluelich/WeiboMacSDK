//
//  WeiboPlace.m
//  Weibo
//
//  Created by Wutian on 14/9/29.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboPlace.h"

@implementation WeiboPlace

+ (NSString *)defaultJSONArrayRootKey
{
    return @"geos";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dict
{
    if ([super updateWithJSONDictionary:dict]) {
        
        CLLocationDegrees latitude = [dict doubleForKey:@"latitude"];
        CLLocationDegrees longitude = [dict doubleForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        self.cityName = [dict stringForKey:@"city_name"];
        self.provinceName = [dict stringForKey:@"province_name"];
        self.address = [dict stringForKey:@"address"];
        
        return YES;
    }
    return NO;
}

- (BOOL)coordinateValid
{
    return CLLocationCoordinate2DIsValid(_coordinate);
}

@end
