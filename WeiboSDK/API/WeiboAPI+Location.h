//
//  WeiboAPI+Location.h
//  Weibo
//
//  Created by Wutian on 10/4/14.
//  Copyright (c) 2014 Wutian. All rights reserved.
//

#import "WeiboAPI.h"

@interface WeiboAPI (Location)

- (void)placesForLatitude:(double)latitude longitude:(double)longitude;

@end
