//
//  WeiboUploadImage.m
//  Weibo
//
//  Created by Wutian on 14-3-30.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboUploadImage.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboAccount+Superpower.h"
#import "NSImage+WeiboAdditions.h"

NSString * const WeiboUploadImageDidStartUploadNotification = @"WeiboUploadImageDidStartUploadNotification";
NSString * const WeiboUploadImageUploadProgressDidUpdateNotification = @"WeiboUploadImageUploadProgressDidUpdateNotification";
NSString * const WeiboUploadImageDidFinishUploadNotification = @"WeiboUploadImageDidFinishUploadNotification";
NSString * const WeiboUploadImageDidFailedToUploadNotification = @"WeiboUploadImageDidFailedToUploadNotification";

@interface WeiboUploadImage ()

@property (nonatomic, assign) CGFloat uploadProgress;
@property (nonatomic, strong) WeiboRequestError * uploadError;
@property (nonatomic, weak) WeiboHTTPRequest * uploadRequest;

@property (nonatomic, strong) NSString * pictureID;

@property (nonatomic, strong) NSData * imageData;

@end

@implementation WeiboUploadImage

+ (instancetype)imageWithNSImage:(NSImage *)image
{
    WeiboUploadImage * uploadImage = [WeiboUploadImage new];
    
    uploadImage.image = image;
    
    return uploadImage;
}

#pragma mark - Accessors

- (BOOL)canUploadSeparatelyWithAccount:(WeiboAccount *)account
{
    return account.superpowerAuthorized;
}

- (BOOL)uploaded
{
    return self.pictureID.length > 0;
}

- (BOOL)uploading
{
    return self.uploadRequest != nil;
}

#pragma mark - Upload

- (void)beginImageUploadWithAccount:(WeiboAccount *)account
{
    if (![self canUploadSeparatelyWithAccount:account] || !self.imageData || self.uploaded || self.uploading) return;
    
    WeiboUploadImage * __weak this = self;
    
    WeiboCallback * callback = WeiboCallbackMake(self, @selector(uploadFinished:info:), nil);
    WeiboAPI * api = [account authenticatedSuperpowerRequest:callback];
    
    [api uploadImageWithData:self.imageData];
    
    [self setUploadProgress:0.0];
    [self setUploadRequest:api.runningRequest];
    [api.runningRequest setUploadProgressBlock:^(CGFloat progress) {
        [this uploadProgressDidUpdate:progress];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUploadImageDidStartUploadNotification object:self];
}
- (void)cancelImageUpload
{
    if (self.uploadRequest)
    {
        [self.uploadRequest cancelRequest];
        [self setUploadRequest:nil];
    }
}

- (void)uploadProgressDidUpdate:(CGFloat)progress
{
    self.uploadProgress = progress;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUploadImageUploadProgressDidUpdateNotification object:self];
}

- (void)uploadFinished:(id)responseObject info:(id)info
{
    [self setUploadProgress:1.0];
    [self setUploadRequest:nil];
    
    if ([responseObject isKindOfClass:[WeiboRequestError class]])
    {
        self.uploadError = responseObject;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUploadImageDidFailedToUploadNotification object:self];
    }
    else
    {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            self.pictureID = [responseObject objectForKey:@"pic_id"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboUploadImageDidFinishUploadNotification object:self];
    }
}

#pragma mark - Image Downsizing

- (void)setImage:(NSImage *)image
{
    // if it is animated gif, don't compress
    if (image.weibo_isAnimatedGIF)
    {
        self.imageData = image.weibo_GIFRepresentation;
        
        return;
    }
    
    // maxiumn image width is 2048, height not limited
    if (image.size.width <= 2048)
    {
        self.imageData = [image weibo_PNGRepresentation];
        
        return;
    }
    
    NSSize targetSize = NSMakeSize(2048, ceil(image.size.height * 2048 / image.size.width));
    
    NSImage * resultImage = [[NSImage alloc] initWithSize:targetSize];
    
    [resultImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, targetSize.width, targetSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [resultImage unlockFocus];
    
    self.imageData = [resultImage weibo_JPEGRepersentationWithCompressFactor:0.92];
}

@end
