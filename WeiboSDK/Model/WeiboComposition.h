//
//  WeiboComposition.h
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WeiboConstants.h"

@class WeiboStatus,WeiboBaseStatus,WeiboUser,WeiboAccount,WTCallback;

@interface WeiboComposition : NSObject <CLLocationManagerDelegate> {
    NSString *text;
    WeiboUser *replyToUser;
    WeiboUser *directMessageUser;
    WeiboStatusID retweetingStatusID;
    WeiboBaseStatus * replyToStatus;
    BOOL isDraft;
    NSData * imageData;
    WTCallback *didSendCallback;
    BOOL dirty;
    BOOL hadFailedSend;
    struct {
        unsigned int didBeginSend:1;
        unsigned int isSending:1;
        unsigned int isWaitingForLocation:1;
    } _flags;
    int urlLength;
    double latitude;
    double longitude;
}

@property(readonly, nonatomic) BOOL isSending;
@property(retain, nonatomic) WeiboUser *replyToUser;
@property(retain, nonatomic) WeiboUser * directMessageUser;
@property(assign, nonatomic) WeiboStatusID retweetingStatusID;
@property(retain, nonatomic) WeiboBaseStatus * replyToStatus;
@property(retain, nonatomic) WTCallback *didSendCallback;
@property(retain, nonatomic) NSData * imageData;
@property(copy, nonatomic) NSString *text;
@property(readonly, nonatomic) int compositionType;
@property(nonatomic) int urlLength;
@property(nonatomic) BOOL hadFailedSend;
@property(nonatomic) BOOL dirty;
@property(nonatomic) BOOL isDraft;



- (void)_sendFromAccount:(WeiboAccount *)account;
- (void)didSend:(id)response;
- (void)errorSending;
- (void)sendFromAccount:(WeiboAccount *)account;
- (void)refreshLocation;

@end
