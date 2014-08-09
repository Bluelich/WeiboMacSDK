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
#import "WeiboCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"
#import "RegexKitLite.h"

@implementation WeiboStatus
@synthesize truncated, retweetedStatus, inReplyToStatusID;
@synthesize geo, favorited, inReplyToUserID, source, sourceUrl;
@synthesize inReplyToScreenname;

- (void)dealloc{
     inReplyToScreenname = nil;
}

#pragma mark -
#pragma mark Parse Methods

+ (void)processObjects:(NSMutableArray *)objects withMetadata:(NSDictionary *)metadata
{
    NSArray * marks = metadata[@"marks"];
    if (marks.count > 0)
    {
        for (NSString * mark in marks)
        {
            if (![mark isKindOfClass:[NSString class]]) continue;
            
            WeiboStatusID sid = (WeiboStatusID)[mark longLongValue];
            if (!sid) continue;
            for (WeiboStatus * status in objects)
            {
                if (status.sid == sid)
                {
                    status.isTopStatus = YES;
                    break;
                }
            }
        }
    }
    
    NSArray * ads = metadata[@"ad"];
    if (ads.count)
    {
        for (NSDictionary * ad in ads)
        {
            if (![ad isKindOfClass:[NSDictionary class]]) continue;
            
            WeiboStatusID statusID = (WeiboStatusID)[ad longlongForKey:@"id" defaultValue:0];
            
            if (!statusID) continue;
            for (WeiboStatus * status in objects)
            {
                if (status.sid == statusID)
                {
                    status.isAdvertisement = YES;
                }
            }
        }
    }
}

+ (NSString *)defaultJSONObjectRootKey
{
    return @"status";
}
+ (NSString *)defaultJSONArrayRootKey
{
    return @"statuses";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dic
{
    if ([super updateWithJSONDictionary:dic])
    {
        
        self.treatRetweetedStatusAsQuoted = YES;
        
        // parse source parameter
		NSString *src = [dic stringForKey:@"source" defaultValue:nil];
		NSRange r = [src rangeOfString:@"<a href"];
		NSRange end;
		if (r.location != NSNotFound) {
			NSRange start = [src rangeOfString:@"<a href=\""];
			if (start.location != NSNotFound) {
				int l = (int)[src length];
				NSRange fromRang = NSMakeRange(start.location + start.length, (NSUInteger)l-start.length-start.location);
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
        self.liked = NO; // we don't have like state
        self.truncated = [dic boolForKey:@"truncated" defaultValue:NO];
        self.inReplyToStatusID = (WeiboStatusID)[dic longlongForKey:@"in_reply_to_status_id" defaultValue:0];
		self.inReplyToUserID = (WeiboUserID)[dic longlongForKey:@"in_reply_to_user_id" defaultValue:0];
		self.inReplyToScreenname = [dic stringForKey:@"in_reply_to_screen_name" defaultValue:@""];
		self.thumbnailPic = [dic stringForKey:@"thumbnail_pic" defaultValue:nil];
		self.middlePic = [dic stringForKey:@"bmiddle_pic" defaultValue:nil];
		self.originalPic = [dic stringForKey:@"original_pic" defaultValue:nil];
        
        NSArray * picURLs = [dic objectForKey:@"pic_urls"];
        
        self.pics = [WeiboPicture objectsWithJSONObject:picURLs account:self.account];
        
        if (!self.pics.count && self.thumbnailPic.length)
        {
            WeiboPicture * picture = [[WeiboPicture alloc] initWithAccount:self.account];
            picture.thumbnailImage = self.thumbnailPic;
            picture.middleImage = self.middlePic;
            picture.originalImage = self.originalPic;
            
            self.pics = @[picture];
        }
        
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic)
        {
            WeiboStatus * retweeted = [WeiboStatus objectWithJSONObject:retweetedStatusDic account:self.account];
			self.retweetedStatus = retweeted;
            self.retweetedStatus.quoted = YES;
		}
        
        return YES;
    }
    return NO;
}

- (WeiboBaseStatus *)quotedBaseStatus
{
    if (self.treatRetweetedStatusAsQuoted)
    {
        return self.retweetedStatus;
    }
    return nil;
}

+ (NSString *)base62FromDouble:(double)value
{
	NSString *base62 = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSUInteger baseLength = [base62 length];
    NSMutableString *returnValue = [NSMutableString string];
	double g = value;
	while (g != 0.)
    {
		NSUInteger x = (NSUInteger)fmod(g,baseLength);
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
	for (int i = ((int)idString.length - 7); i > -7; i = i - 7)
    {
		NSString * temp = [idString substringWithRange:NSMakeRange((NSUInteger)(i < 0? 0:i), (NSUInteger)(i < 0? i + 7:7))];
		temp = [self base62FromDouble:[temp doubleValue]];
        NSUInteger zerosToFill = 4 - temp.length;
        if (i > 0)
        {
            for (NSUInteger j = 0; j < zerosToFill; j++)
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
