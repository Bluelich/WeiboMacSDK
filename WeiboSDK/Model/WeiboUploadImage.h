//
//  WeiboUploadImage.h
//  Weibo
//
//  Created by Wutian on 14-3-30.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WeiboUploadImageDidStartUploadNotification;
extern NSString * const WeiboUploadImageUploadProgressDidUpdateNotification;
extern NSString * const WeiboUploadImageDidFinishUploadNotification;
extern NSString * const WeiboUploadImageDidFailedToUploadNotification;

@class WeiboAccount, WeiboRequestError;

@interface WeiboUploadImage : NSObject

+ (instancetype)imageWithNSImage:(NSImage *)image account:(WeiboAccount *)account;

@property (nonatomic, strong, readonly) WeiboAccount * account;
@property (nonatomic, strong, readonly) NSData * imageData;

@property (nonatomic, assign, readonly) BOOL canUploadSeparately;

- (void)beginImageUpload;
- (void)cancelImageUpload;

@property (nonatomic, assign, readonly) BOOL uploading;
@property (nonatomic, assign, readonly) BOOL uploaded;
@property (nonatomic, assign, readonly) CGFloat uploadProgress;
@property (nonatomic, strong, readonly) WeiboRequestError * uploadError;
@property (nonatomic, strong, readonly) NSString * pictureID;

@end
