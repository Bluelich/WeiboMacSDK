//
//  NSImage+WeiboAdditions.m
//  Weibo
//
//  Created by Wutian on 14-3-30.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "NSImage+WeiboAdditions.h"

@implementation NSImage (WeiboAdditions)

- (BOOL)weibo_isAnimatedGIF
{
    @try
    {
		NSArray * reps = [self representations];
		for (NSImageRep * rep in reps)
		{
			if ([rep isKindOfClass:[NSBitmapImageRep class]] == YES)
			{
				NSBitmapImageRep * bitmapRep = (NSBitmapImageRep *)rep;
				int numFrame = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
				return numFrame > 1;
			}
		}
	}
    @catch (NSException * e)
    {
        
	}
	return NO;
}

- (NSData *)weibo_GIFRepresentation
{
    NSArray * reps = [self representations];
    for (NSImageRep * rep in reps)
    {
        if ([rep isKindOfClass:[NSBitmapImageRep class]] == YES)
        {
            NSBitmapImageRep * bitmapRep = (NSBitmapImageRep *)rep;
            int numFrame = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
            
            if (numFrame == 0)
            {
                return [bitmapRep representationUsingType:NSGIFFileType properties: nil];
            }
            
            NSMutableData * imageData = [NSMutableData data];
            
            // set the place to save the GIF to
            CGImageDestinationRef animatedGIF = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData,
                                                                                 kUTTypeGIF,
                                                                                 numFrame,
                                                                                 NULL
                                                                                 );
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast; //kCGImageAlphaNoneSkipFirst
            
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
            int bitsPerComponent = 8;
            
            for (int i = 0; i < numFrame; ++i)
            {
                [bitmapRep setProperty:NSImageCurrentFrame withValue:@(i)];
                
                CGDataProviderRef frameProvider = CGDataProviderCreateWithData(NULL,
                                                                               [bitmapRep bitmapData],
                                                                               [bitmapRep bytesPerRow] * [bitmapRep pixelsHigh],
                                                                               NULL
                                                                               );
                
                CGImageRef cgFrame = CGImageCreate ([bitmapRep pixelsWide],
                                                    [bitmapRep pixelsHigh],
                                                    bitsPerComponent,
                                                    [bitmapRep bitsPerPixel],
                                                    [bitmapRep bytesPerRow],
                                                    colorSpaceRef,
                                                    bitmapInfo,
                                                    frameProvider,
                                                    NULL,
                                                    NO,
                                                    kCGRenderingIntentDefault
                                                    );
                
                if (cgFrame) {
                    
                    float duration = [[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue];
                    
                    NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFDelayTime : @(duration)}};
                    
                    CGImageDestinationAddImage(animatedGIF, cgFrame, (__bridge CFDictionaryRef)frameProperties);
                    CGImageRelease(cgFrame);
                }
                
                CGDataProviderRelease(frameProvider);
                
            }
            
            CGColorSpaceRelease(colorSpaceRef);
            
            
            NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFLoopCount : @0}};
            
            CGImageDestinationSetProperties(animatedGIF, (__bridge CFDictionaryRef) gifProperties);
            CGImageDestinationFinalize(animatedGIF);
            CFRelease(animatedGIF);
            
            return imageData;
        }
    }
    return nil;
}

- (NSData *)weibo_PNGRepresentation
{
    NSArray * reps = [self representations];
    for (NSImageRep * rep in reps)
    {
        if ([rep isKindOfClass:[NSBitmapImageRep class]] == YES)
        {
            NSBitmapImageRep * bitmapRep = (NSBitmapImageRep *)rep;
            
            return [bitmapRep representationUsingType:NSPNGFileType properties: nil];
        }
    }
    return nil;
}

- (NSData *)weibo_JPEGRepersentationWithCompressFactor:(CGFloat)factor
{
    NSArray * reps = [self representations];
    for (NSImageRep * rep in reps)
    {
        if ([rep isKindOfClass:[NSBitmapImageRep class]] == YES)
        {
            NSBitmapImageRep * bitmapRep = (NSBitmapImageRep *)rep;
            return [bitmapRep representationUsingType:NSPNGFileType properties:@{NSImageCompressionFactor: @(factor)}];
        }
    }
    return nil;
}

@end
