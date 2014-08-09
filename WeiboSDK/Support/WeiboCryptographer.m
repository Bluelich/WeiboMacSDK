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
    _keyGeneration = nil;
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
    
    NSLog(@"<Token> 将进行加密 text:%@, salt:%@, key:%@", text.weibo_stringForLogging, salt, key);
    
    NSString * resultString = nil;
    
    @try {
        CocoaSecurityResult * result = [CocoaSecurity aesEncrypt:text key:key];
        resultString = result.base64;
    }
    @catch (NSException *exception) {
        resultString = nil;
    }
    
    NSLog(@"<Token> 加密的结果为: %@", resultString);
    
    return resultString;
}
- (NSString *)decryptText:(NSString *)text salt:(NSString *)salt
{
    if (!text) return nil;
    
    NSString * key = [self cryptoKeyWithSalt:salt];
    NSString * resultString = nil;
    
    NSLog(@"<Token> 将进行解密 text:%@, salt:%@, key:%@", text, salt, key);
    
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

@implementation NSString (WeiboCryptographer)

- (NSString *)weibo_stringForLogging
{
    if (self.length > 8)
    {
        return [NSString stringWithFormat:@"%@****%@", [self substringToIndex:4], [self substringFromIndex:self.length - 4]];
    }
    return self;
}

@end
