//
//  WeiboCryptographer.h
//  Weibo
//
//  Created by Wutian on 14-2-14.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboCryptographer : NSObject

+ (instancetype)sharedCryptographer;

@property (nonatomic, copy) NSString * (^keyGeneration)(NSString * salt);

- (NSString *)encryptText:(NSString *)text salt:(NSString *)salt;
- (NSString *)decryptText:(NSString *)text salt:(NSString *)salt;

@end

@interface NSString (WeiboCryptographer)

@property (nonatomic, readonly) NSString * stringForLogging;

@end
