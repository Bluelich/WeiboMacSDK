//
//  WeiboComposition.m
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboComposition.h"
#import "WeiboAccount.h"
#import "WeiboAPI.h"
#import "WeiboBaseStatus.h"
#import "WTCallback.h"

@implementation WeiboComposition
@synthesize isSending, replyToUser, directMessageUser, retweetingStatusID, didSendCallback;
@synthesize text, compositionType, urlLength, hadFailedSend, dirty, isDraft, imageData;
@synthesize replyToStatus;

#pragma mark -
#pragma mark Object Life Cycle

- (void)dealloc{
    self.replyToUser = nil;
    self.directMessageUser = nil;
    self.didSendCallback = nil;
    self.text = nil;
    self.replyToStatus = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Sending
- (void)_sendFromAccount:(WeiboAccount *)account{
    WTCallback * callback = WTCallbackMake(self, @selector(didSend:), nil);
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api updateWithComposition:self];
}
- (void)didSend:(id)response{
    NSLog(@"response:%@",response);
    if (didSendCallback) {
        [didSendCallback invoke:response];
    }
}
- (void)errorSending{
    
}
- (void)sendFromAccount:(WeiboAccount *)account{
    [self _sendFromAccount:account];
}

#pragma mark -
#pragma mark Locaion (Delegate) Methods
- (void)refreshLocation{
    CLLocationManager * manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    [manager startUpdatingLocation];
}

- (void)doneRefreshingLocation{
    NSLog(@"new location: %f, %f",latitude,longitude);
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation{
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    [self doneRefreshingLocation];
    [manager stopUpdatingLocation];
    [manager autorelease];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // handle error here
    NSLog(@"error:%@",error);
    [self doneRefreshingLocation];
    [manager stopUpdatingLocation];
    [manager autorelease];
}
@end
