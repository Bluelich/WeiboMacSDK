//
//  WeiboUploadImage.m
//  Weibo
//
//  Created by Wutian on 14-3-30.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboUploadImage.h"
#import "WeiboAccount+Superpower.h"

NSString * const WeiboUploadImageDidStartUploadNotification = @"WeiboUploadImageDidStartUploadNotification";
NSString * const WeiboUploadImageUploadProgressDidUpdateNotification = @"WeiboUploadImageUploadProgressDidUpdateNotification";
NSString * const WeiboUploadImageDidFinishUploadNotification = @"WeiboUploadImageDidFinishUploadNotification";
NSString * const WeiboUploadImageDidFailedToUploadNotification = @"WeiboUploadImageDidFailedToUploadNotification";

@interface WeiboUploadImage ()

@property (nonatomic, strong) WeiboAccount * account;

@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, assign) CGFloat uploadProgress;
@property (nonatomic, strong) WeiboRequestError * uploadError;
@property (nonatomic, strong) NSString * pictureID;

@property (nonatomic, strong) NSData * imageData;

@end

@implementation WeiboUploadImage

+ (instancetype)imageWithNSImage:(NSImage *)image account:(WeiboAccount *)account
{
    WeiboUploadImage * uploadImage = [WeiboUploadImage new];
    
    uploadImage.account = account;
    uploadImage.image = image;
    
    return uploadImage;
}

#pragma mark - Accessors

- (BOOL)canUploadSeparately
{
    return self.account.superpowerAuthorized;
}

#pragma mark - Upload

- (void)beginImageUpload
{
    
}
- (void)cancelImageUpload
{
    
}

#pragma mark - Image Downsizing

- (void)setImage:(NSImage *)image
{
    // if it is animated gif, don't compress
    
    // maxiumn image width is 2048, height not limited
}

@end
