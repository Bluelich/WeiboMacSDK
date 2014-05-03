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

+ (instancetype)imageWithImageData:(NSData *)imageData;

@property (nonatomic, strong, readonly) NSData * imageData;

- (BOOL)canUploadSeparatelyWithAccount:(WeiboAccount *)account;

- (void)beginImageUploadWithAccount:(WeiboAccount *)account;
- (void)cancelImageUpload;

@property (nonatomic, assign, readonly) BOOL uploading;
@property (nonatomic, assign, readonly) BOOL uploaded;
@property (nonatomic, assign, readonly) CGFloat uploadProgress;
@property (nonatomic, strong, readonly) WeiboRequestError * uploadError;
@property (nonatomic, strong, readonly) NSString * pictureID;

@end
