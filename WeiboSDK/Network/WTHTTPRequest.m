//
//  WTHTTPRequest.m
//  Weibo
//
//  Created by Wu Tian on 12-2-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTHTTPRequest.h"
#import "WeiboRequestError.h"
#import "WTCallback.h"

#import "OAuthConsumer.h"
#import "WTOASingnaturer.h"

@interface WTHTTPRequest()
- (void)postFailWithError:(NSError *)error;
- (NSString *)oAuthAuthorizationHeader;
- (NSString *)_parameterStringByDictionary:(NSDictionary *) parameters;
@end

@implementation WTHTTPRequest
@synthesize responseCallback, oAuthToken, oAuthTokenSecret, parameters;
@synthesize oAuth2Token = _oAuth2Token;

+ (WTHTTPRequest *)requestWithURL:(NSURL *)url{
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)newURL
{
    if ((self = [super initWithURL:newURL])) {
        [self setDelegate:self];
        [self setValidatesSecureCertificate:NO];
        [self setDefaultResponseEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (NSStringEncoding)responseEncoding
{
    if (!responseEncoding)
    {
        return NSUTF8StringEncoding;
    }
    return responseEncoding;
}

- (void)prepareAuthrize
{
    if ([[self requestMethod] isEqualToString:@"GET"]) {
        NSURL * urlWithQuery = [NSURL URLWithString:[self _parameterStringByDictionary:parameters] 
                                      relativeToURL:[self url]];
        [self setURL:urlWithQuery];
    }else{
        for(NSString * key in parameters){
            NSString * value = [parameters objectForKey:key];
            if(value != nil){
                [self addPostValue:value forKey:key];
            }
        }
    }
}
- (void)v1_startAuthrizedRequest
{
    [self prepareAuthrize];
    [self addRequestHeader:@"Authorization" value:[self v1_oAuthAuthorizationHeader]];
    [self startAsynchronous];
}
- (void)startAuthrizedRequest
{
    // Two ways to complete OAuth.
    /*
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:self.parameters];
    [params setValue:self.oAuth2Token forKey:@"access_token"];
    self.parameters = params;
     */
    [self prepareAuthrize];
    [self addRequestHeader:@"Authorization" value:[self oAuthAuthorizationHeader]];
    [self startAsynchronous];
}


- (NSString *)oAuthAuthorizationHeader{
    return [NSString stringWithFormat:@"OAuth2 %@",self.oAuth2Token];
}
- (NSString *)v1_oAuthAuthorizationHeader{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:WEIBO_CONSUMER_KEY
													secret:WEIBO_CONSUMER_SECRET];
    OAToken * token = [[OAToken alloc] initWithKey:oAuthToken secret:oAuthTokenSecret];
    WTOASingnaturer *singnaturer = [[WTOASingnaturer alloc] initWithURL:[[self url] absoluteString]
                                                           consumer:consumer
                                                              token:token
                                                              realm:nil
                                                  signatureProvider:nil];
    
    NSArray * keys = [parameters allKeys];
    NSMutableArray * parameter = [[NSMutableArray alloc] initWithCapacity:[keys count]];
    for (id key in keys) {
        OARequestParameter * requestParameter = [[OARequestParameter alloc] initWithName:key value:[parameters valueForKey:key]];
        [parameter addObject:requestParameter];
    }
    
    [singnaturer setParameters:parameter];
	[singnaturer setMethod:[self requestMethod]];
    [singnaturer setUrlStringWithoutQuery:[[[[self url] absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0]];
    NSString *authString = [NSString stringWithString:[singnaturer getSingnatureString]];
    
    return authString;
}

- (NSString *)_parameterStringByDictionary:(NSDictionary *) params{
	NSMutableString * result = [NSMutableString string];
    BOOL isFirstParameter = YES;
	for(NSString * key in params){
		NSString * value = [params objectForKey:key];
		if(value != nil){
            if(isFirstParameter) 
                [result appendString:@"?"];
            else 
                [result appendString:@"&"];
            isFirstParameter = NO;
			[result appendFormat:@"%@=%@",key,value];
		}
	}
	return [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)postFailWithError:(NSError *)aError
{
    NSLog(@"error response:%@",[self responseString]);
    [responseCallback invoke:aError];
}

#pragma mark -
#pragma mark Request delegates

- (void)requestError:(ASIHTTPRequest *)request
{
    WeiboRequestError * requestError = [WeiboRequestError
                                        errorWithResponseString:[self responseString] statusCode:self.responseStatusCode];
    [self postFailWithError:requestError];
}
- (void)requestSuccess:(ASIHTTPRequest *)request
{
    NSString * responseString = [self responseString];
    [responseCallback invoke:responseString];
}

- (void)requestFinished:(ASIHTTPRequest *)aRequest
{
    if (responseStatusCode == 200)
    {
        [self requestSuccess:aRequest];
    }
    else
    {
        [self requestError:aRequest];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)aRequest
{
    if (responseStatusCode == 200)
    {
        [self requestSuccess:aRequest];
    }
    else
    {
        [self requestError:aRequest];
    }
}

@end
