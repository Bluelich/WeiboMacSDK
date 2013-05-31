//
//  WeiboStatus.m
//  Weibo
//
//  Created by Wu Tian on 12-2-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStatus.h"
#import "WeiboGeotag.h"
#import "WeiboUser.h"
#import "WeiboPicture.h"
#import "WTCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"
#import "RegexKitLite.h"

@implementation WeiboStatus
@synthesize truncated, retweetedStatus, inReplyToStatusID;
@synthesize geo, favorited, inReplyToUserID, source, sourceUrl;
@synthesize inReplyToScreenname;

- (void)dealloc{
    [retweetedStatus release]; retweetedStatus = nil;
    [geo release]; geo = nil;
    [source release]; source = nil;
    [sourceUrl release]; sourceUrl = nil;
    [inReplyToScreenname release]; inReplyToScreenname = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Parse Methods
+ (WeiboStatus *)statusWithDictionary:(NSDictionary *)dic{
    return [[[[self class] alloc] initWithDictionary:dic] autorelease];
}
+ (WeiboStatus *)statusWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    WeiboStatus * status = [[self class] statusWithDictionary:dictionary];
    return status;
}
+ (NSArray *)statusesWithJSON:(NSString *)json{
    NSDictionary * jsonObject = [json objectFromJSONString];
    NSArray * dictionaries = [jsonObject objectForKey:@"statuses"];
    NSMutableArray * statuses = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboStatus * status = [WeiboStatus statusWithDictionary:dic];
        [statuses addObject:status];
    }
    return statuses;
}
+ (void)parseStatusesJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSArray * statuses = [self statusesWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:statuses];
            [json release];
            [NSString clearStringCache];
        });
    });
}
+ (void)parseStatusJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        WeiboStatus * status = [self statusWithJSON:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [callback invoke:status];
            [json release];
        });
    });
}

- (WeiboStatus *)_initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.sid = [dic longlongForKey:@"id" defaultValue:-1];
		self.createdAt = [dic timeForKey:@"created_at" defaultValue:0];
		self.text = [dic stringForKey:@"text" defaultValue:@""];
        
        // parse source parameter
		NSString *src = [dic stringForKey:@"source" defaultValue:nil];
		NSRange r = [src rangeOfString:@"<a href"];
		NSRange end;
		if (r.location != NSNotFound) {
			NSRange start = [src rangeOfString:@"<a href=\""];
			if (start.location != NSNotFound) {
				int l = (int)[src length];
				NSRange fromRang = NSMakeRange(start.location + start.length, l-start.length-start.location);
				end   = [src rangeOfString:@"\"" options:NSCaseInsensitiveSearch 
                                     range:fromRang];
				if (end.location != NSNotFound) {
					r.location = start.location + start.length;
					r.length = end.location - r.location;
					self.sourceUrl = [src substringWithRange:r];
				}
				else {
					self.sourceUrl = nil;
				}
			}
			else {
				self.sourceUrl = nil;
			}			
			start = [src rangeOfString:@"\">"];
			end   = [src rangeOfString:@"</a>"];
			if (start.location != NSNotFound && end.location != NSNotFound) {
				r.location = start.location + start.length;
				r.length = end.location - r.location;
				self.source = [src substringWithRange:r];
			}
			else {
				self.source = nil;
			}
		}
		else {
			self.source = src;
		}
        
        
        self.favorited = [dic boolForKey:@"favorited" defaultValue:NO];
        self.truncated = [dic boolForKey:@"truncated" defaultValue:NO];
        self.inReplyToStatusID = [dic longlongForKey:@"in_reply_to_status_id" defaultValue:-1];
		self.inReplyToUserID = [dic intForKey:@"in_reply_to_user_id" defaultValue:-1];
		self.inReplyToScreenname = [dic stringForKey:@"in_reply_to_screen_name" defaultValue:@""];
		self.thumbnailPic = [dic stringForKey:@"thumbnail_pic" defaultValue:nil];
		self.middlePic = [dic stringForKey:@"bmiddle_pic" defaultValue:nil];
		self.originalPic = [dic stringForKey:@"original_pic" defaultValue:nil];
        
        NSArray * picURLs = [dic objectForKey:@"pic_urls"];
        NSMutableArray * pics = [NSMutableArray array];
        
        for (NSDictionary * dict in picURLs)
        {
            if ([dict isKindOfClass:[NSDictionary class]])
            {
                WeiboPicture * picture = [WeiboPicture pictureWithDictionary:dict];
                
                if (picture)
                {
                    [pics addObject:picture];
                }
            }
        }
        
        self.pics = pics;
        
        if (!self.pics.count && self.thumbnailPic.length)
        {
            WeiboPicture * picture = [WeiboPicture new];
            picture.thumbnailImage = self.thumbnailPic;
            picture.middleImage = self.middlePic;
            picture.originalImage = self.originalPic;
            
            self.pics = @[picture];
            
            [picture release];
        }
        
        NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic && ![userDic isKindOfClass:[NSNull class]]) {
			self.user = [WeiboUser userWithDictionary:userDic];
		}
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic) {
            WeiboStatus * retweeted = [[WeiboStatus alloc] _initWithDictionary:retweetedStatusDic];
			self.retweetedStatus = retweeted;
            self.retweetedStatus.quoted = YES;
            [retweeted release];
		}
    }
    return self;
}

- (WeiboBaseStatus *)quotedBaseStatus
{
    return self.retweetedStatus;
}

+ (NSString *)base62FromDouble:(double)value
{
	NSString *base62 = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger baseLength = [base62 length];
    NSMutableString *returnValue = [NSMutableString string];
	double g = value;
	while (g != 0)
    {
		int x = fmod(g,baseLength);
		NSString *y = [base62 substringWithRange:NSMakeRange(x, 1)];
		[returnValue insertString:y atIndex:0];
		value /= baseLength;
		g = round(value - 0.5);
	}
	return returnValue;
}
+ (NSString *)midFromId:(WeiboStatusID)sid
{
    NSMutableString * url = [NSMutableString string];
	NSString * idString = [NSString stringWithFormat:@"%lld",sid];
	for (int i = (int)(idString.length - 7); i > -7; i = i - 7)
    {
		NSString * temp = [idString substringWithRange:NSMakeRange(i < 0? 0:i, i < 0? i + 7:7)];
		temp = [self base62FromDouble:[temp doubleValue]];
        NSInteger zerosToFill = 4 - temp.length;
        if (i > 0)
        {
            for (int j = 0; j < zerosToFill; j++)
            {
                [url insertString:@"0" atIndex:0];
            }
        }
        else
        {
            zerosToFill = 0;
        }
		[url insertString:temp atIndex:zerosToFill];
	}
    return url;
}
- (NSURL *)webLink
{
    NSString * url = [NSString stringWithFormat:@"http://weibo.com/%lld/%@",self.user.userID,[[self class] midFromId:self.sid]];
    return [NSURL URLWithString:url];
}

@end
