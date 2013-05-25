//
//  WeiboComposition.h
//  Weibo
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboUser.h"
#import "WeiboBaseStatus.h"

enum {
	WeiboCompositionTypeNewTweet,
	WeiboCompositionTypeComment,
    WeiboCompositionTypeRetweet,
};
typedef NSInteger WeiboCompositionType;

@protocol WeiboComposition <NSObject>

@property (nonatomic, copy)   NSString * text;
@property (nonatomic, retain) WeiboUser *replyToUser;
@property (nonatomic, retain) WeiboUser * directMessageUser;
@property (nonatomic, retain) WeiboBaseStatus * retweetingStatus;
@property (nonatomic, retain) WeiboBaseStatus * replyToStatus;
@property (nonatomic, assign) WeiboCompositionType type;

@property (nonatomic, retain) NSData * imageData;

- (void)didSend:(id)response;
- (void)errorSending;

@end
