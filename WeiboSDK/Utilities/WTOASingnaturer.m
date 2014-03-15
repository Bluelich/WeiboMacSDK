//
//  WTOASingnaturer.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTOASingnaturer.h"
#import "OARequestParameter.h"
#import "NSString+URLEncoding.h"
#import "OAHMAC_SHA1SignatureProvider.h"

@interface WTOASingnaturer (Private)
- (void)_generateTimestamp;
- (void)_generateNonce;
- (NSString *)_signatureBaseString;
- (NSString *) _getHttpMethodName;
@end

@implementation WTOASingnaturer

@synthesize signature, nonce ,urlStringWithoutQuery,parameters,method ;

#pragma mark Public

- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider 
{
	self = [super init];
	if(self != nil){ 
		urlStringWithoutQuery = urlString;
		consumer = aConsumer;
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = aToken;
		
		if (aRealm == nil)
			realm = @"";
		else 
			realm = aRealm;
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = aProvider;
		
		[self _generateTimestamp];
		[self _generateNonce];
	}
    return self;
}

// Setting a timestamp and nonce to known
// values can be helpful for testing
- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp 
{
	self = [super init];
	if(self != nil){ 
		urlStringWithoutQuery = urlString;
		consumer = aConsumer;
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = aToken;
		
		if (aRealm == nil)
			realm = @"";
		else 
			realm = aRealm;
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = aProvider;
		
		timestamp = aTimestamp;
		nonce = aNonce;
	}
    return self;
}


#pragma mark -
#pragma mark Public

- (NSString *)getSingnatureString 
{
    // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
    NSString * clearText = [self _signatureBaseString];
    signature = [signatureProvider signClearText:clearText
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    
    //NSLog(@"\nsingnatureing,\nconsumer:%@\ntoken:%@",consumer.secret,token.secret);
	// set OAuth headers
    NSString *oauthToken;
    
    if (!token.key || [token.key isEqualToString:@""]){
		oauthToken = @"";
    }else{
        oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [token.key URLEncodedString]];
    }
    /*
	else if(token.verifier == nil || [token.verifier isEqualToString:@""])
		oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [token.key URLEncodedString]];
	else
		oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", oauth_verifier=\"%@\", ", [token.key URLEncodedString], [token.verifier URLEncodedString]];
    */
	NSMutableString *extraParameters = [NSMutableString string];
	
	// Adding the optional parameters in sorted order isn't required by the OAuth spec, but it makes it possible to hard-code expected values in the unit tests.
	for(NSString *parameterName in [[extraOAuthParameters allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		[extraParameters appendFormat:@", %@=\"%@\"",
		 [parameterName URLEncodedString],
		 [[extraOAuthParameters objectForKey:parameterName] URLEncodedString]];
	}	

    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"%@",
                             [realm URLEncodedString],
                             [consumer.key URLEncodedString],
                             oauthToken,
                             [[signatureProvider name] URLEncodedString],
                             [signature URLEncodedString],
                             timestamp,
                             nonce,
							 extraParameters];
    //NSLog(@"%@",oauthHeader);
    
	return oauthHeader;
}

- (NSString *)getXauthSingnatureString{
    signature = [signatureProvider signClearText:[self _signatureBaseString]
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    
    //NSLog(@"\nsingnatureing,\nconsumer:%@\ntoken:%@",consumer.secret,token.secret);
	// set OAuth headers
    NSString *oauthToken = @"";
    
	NSMutableString *extraParameters = [[NSMutableString alloc] initWithString:@""];
	
	// Adding the optional parameters in sorted order isn't required by the OAuth spec, but it makes it possible to hard-code expected values in the unit tests.
	for(NSString *parameterName in [[extraOAuthParameters allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		[extraParameters appendFormat:@", %@=\"%@\"",
		 [parameterName URLEncodedString],
		 [[extraOAuthParameters objectForKey:parameterName] URLEncodedString]];
	}
    //NSLog(@"parameters:%@",extraParameters);
    
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"%@, source=\"83996567\"",
                             [realm URLEncodedString],
                             [consumer.key URLEncodedString],
                             oauthToken,
                             [[signatureProvider name] URLEncodedString],
                             [signature URLEncodedString],
                             timestamp,
                             nonce,
                             extraParameters];
    //NSLog(@"oauthHeader:%@",oauthHeader);
	return oauthHeader;
}

- (NSString *)getQueryString 
{
    // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
    signature = [signatureProvider signClearText:[self _signatureBaseString]
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    // set OAuth headers
    NSString *callbackURL= @"oauth_callback=weibomac%3A%2F%2F";// set your callback here
    
    NSString *queryString = [NSString stringWithFormat:@"oauth_consumer_key=%@&%@&oauth_signature_method=%@&oauth_signature=%@&oauth_timestamp=%@&oauth_nonce=%@&oauth_version=1.0",
                             [consumer.key URLEncodedString],
                             callbackURL,
                             [[signatureProvider name] URLEncodedString],
                             [signature URLEncodedString],
                             timestamp,
                             nonce];
	return queryString;
}


- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue
{
	assert(parameterName && parameterValue);
	
	if (extraOAuthParameters == nil) {
		extraOAuthParameters = [NSMutableDictionary new];
	}
	
	[extraOAuthParameters setObject:parameterValue forKey:parameterName];
}

#pragma mark -
#pragma mark Private

- (void)_generateTimestamp 
{
    timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
}

- (void)_generateNonce 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    nonce = (__bridge NSString *)string;
}


- (NSString *)_signatureBaseString 
{
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
    NSUInteger paramaterCount = 0;
    if (parameters) {
        paramaterCount = [parameters count];
    }
    NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(6 + paramaterCount)]; // 6 being the number of OAuth params in the Signature Base String
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
    
    if (![token.key isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
        /*
		if (token.verifier != nil && ![token.verifier isEqualToString:@""]) {
			[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_verifier" value:token.verifier] URLEncodedNameValuePair]];
		}
        else{
            
            
            
        }*/
    }
	else 
	{
	}
    

    for (OARequestParameter *param in parameters) {
        //NSLog(@"adding param:%@",[param description]);
        [parameterPairs addObject:[param URLEncodedNameValuePair]];
    }
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
	NSString * httpMethod = [self _getHttpMethodName];
	
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 httpMethod,
					 [urlStringWithoutQuery URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
    
    //NSLog(@"basestring:%@",ret);

	return ret;
}

- (NSString *) _getHttpMethodName{
	return method;
}

@end
