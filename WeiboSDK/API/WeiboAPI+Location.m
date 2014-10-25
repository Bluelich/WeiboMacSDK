//
//  WeiboAPI+Location.m
//  Weibo
//
//  Created by Wutian on 10/4/14.
//  Copyright (c) 2014 Wutian. All rights reserved.
//

#import "WeiboAPI+Location.h"
#import "WeiboAPI+Private.h"
#import <CoreLocation/CoreLocation.h>

@implementation WeiboAPI (Location)

- (void)placesForLatitude:(double)latitude longitude:(double)longitude
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        [self requestFailedWithErrorCode:WeiboErrorCodeParametersInvalid];
        return;
    }
    
    NSString * coordinateString = [NSString stringWithFormat:@"%f,%f", longitude, latitude];
    
    [self GET:@"location/geo/geo_to_address.json" parameters:@{@"coordinate": coordinateString} callback:WeiboBlockCallback(^(id responseObject) {
        if (responseObject) {
#warning Unfinished...
        }
    })];
}

@end
