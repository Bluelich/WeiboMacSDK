//
//  NSImage+WeiboAdditions.h
//  Weibo
//
//  Created by Wutian on 14-3-30.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (WeiboAdditions)

@property (nonatomic, assign, readonly) BOOL weibo_isAnimatedGIF;
@property (nonatomic, strong, readonly) NSData * weibo_GIFRepresentation;
@property (nonatomic, strong, readonly) NSData * weibo_PNGRepresentation;

@end
