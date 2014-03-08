//
//  WeiboCryptographer.m
//  Weibo
//
//  Created by Wutian on 14-2-14.
//  Copyright (c) 2014年 Wutian. All rights reserved.
//

#import "WeiboCryptographer.h"
#import "CocoaSecurity.h"

@implementation WeiboCryptographer

- (void)dealloc
{
    [_keyGeneration release], _keyGeneration = nil;
    [super dealloc];
}

+ (instancetype)sharedCryptographer
{
    static WeiboCryptographer * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WeiboCryptographer alloc] init];
    });
    return instance;
}

- (NSString *)cryptoKeyWithSalt:(NSString *)salt
{
    if (self.keyGeneration)
    {
        return self.keyGeneration(salt);
    }
    return [NSString stringWithFormat:@"com.wutian.weibo.%@.AESKey", salt];
}

- (NSString *)encryptText:(NSString *)text salt:(NSString *)salt
{
    if (!text) return nil;
    
    NSString * key = [self cryptoKeyWithSalt:salt];
    NSString * resultString = nil;
    
    @try {
        CocoaSecurityResult * result = [CocoaSecurity aesEncrypt:text key:key];
        resultString = result.base64;
    }
    @catch (NSException *exception) {
        resultString = nil;
    }
    return resultString;
}
- (NSString *)decryptText:(NSString *)text salt:(NSString *)salt
{
    if (!text) return nil;
    
    NSString * key = [self cryptoKeyWithSalt:salt];
    NSString * resultString = nil;
    
    @try {
        CocoaSecurityResult * result = [CocoaSecurity aesDecryptWithBase64:text key:key];
        resultString = result.utf8String;
    }
    @catch (NSException *exception) {
        resultString = nil;
    }
    return resultString;
}

@end
