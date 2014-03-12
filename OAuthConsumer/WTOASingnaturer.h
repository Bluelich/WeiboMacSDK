//
//  WTOASingnaturer.h
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OASignatureProviding.h"

@interface WTOASingnaturer : NSObject {
@protected
    OAConsumer *consumer;
    OAToken *token;
    NSString *realm;
    NSString *__weak signature;
    id<OASignatureProviding> signatureProvider;
    NSString *nonce;
    NSString *timestamp;
	NSArray *parameters;
	NSMutableDictionary *extraOAuthParameters;
	NSString *urlStringWithoutQuery;
    NSString *__weak method;
}
@property(weak, readonly) NSString *signature;
@property(readonly) NSString *nonce;
@property(strong) NSString * urlStringWithoutQuery;
@property(strong) NSArray * parameters;
@property(weak) NSString * method;

- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp;

- (NSString *)getSingnatureString;
- (NSString *)getXauthSingnatureString;
- (NSString *)getQueryString ;
- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue;

@end
