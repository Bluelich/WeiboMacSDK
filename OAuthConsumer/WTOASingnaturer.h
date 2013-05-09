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
    NSString *signature;
    id<OASignatureProviding> signatureProvider;
    NSString *nonce;
    NSString *timestamp;
	NSArray *parameters;
	NSMutableDictionary *extraOAuthParameters;
	NSString *urlStringWithoutQuery;
    NSString *method;
}
@property(readonly) NSString *signature;
@property(readonly) NSString *nonce;
@property(retain) NSString * urlStringWithoutQuery;
@property(retain) NSArray * parameters;
@property(assign) NSString * method;

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
