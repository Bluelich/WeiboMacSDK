//
//  WeiboComposition.h
//  Weibo
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WeiboUser.h"
#import "WeiboBaseStatus.h"

enum {
	WeiboCompositionTypeNewTweet,
	WeiboCompositionTypeComment,
    WeiboCompositionTypeRetweet,
    WeiboCompositionTypeDirectMessage,
};
typedef NSInteger WeiboCompositionType;

@protocol WeiboComposition <NSObject>

@property (nonatomic, copy)   NSString * text;
@property (nonatomic, retain) WeiboUser *replyToUser;
@property (nonatomic, retain) WeiboUser * directMessageUser;
@property (nonatomic, retain) WeiboBaseStatus * retweetingStatus;
@property (nonatomic, retain) WeiboBaseStatus * replyToStatus;
@property (nonatomic, assign) WeiboCompositionType type;

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@property (nonatomic, assign, readonly) NSInteger characterLimit;
@property (nonatomic, assign, readonly) NSInteger uploadImageCountLimit;

@property (nonatomic, retain) NSArray * uploadImages; // objects of WeiboUploadImage class

- (void)didSend:(id)response;
- (void)errorSending;

- (BOOL)isDirectMessage;

- (BOOL)canPostImage;
- (BOOL)requiresUserInput;

@end

NS_INLINE NSInteger WeiboCompositionTextLength(NSString * text)
{
    NSInteger idx, length = [text length], sbc = 0, ascii = 0, blank = 0;
    for(idx = 0; idx < length; idx++)
    {
        unichar c = [text characterAtIndex:idx];
        if (isblank(c))
        {
            blank++;
        }
        else if(isascii(c))
        {
            ascii++;
        }
        else
        {
            sbc++;
        }
    }
    
    if (!ascii && !sbc) return 0;

    return sbc + (NSInteger)ceilf((float)(ascii + blank)/2.0);
}
