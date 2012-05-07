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
#import "WTCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"
#import "RegexKitLite.h"

@implementation WeiboStatus
@synthesize truncated, retweetedStatus, inReplyToStatusID;
@synthesize geo, favorited, inReplyToUserID, source, sourceUrl;
@synthesize thumbnailPic, middlePic, originalPic, inReplyToScreenname;

- (void)dealloc{
    [retweetedStatus release]; retweetedStatus = nil;
    [geo release]; geo = nil;
    [source release]; source = nil;
    [sourceUrl release]; sourceUrl = nil;
    [thumbnailPic release]; thumbnailPic = nil;
    [middlePic release]; middlePic = nil;
    [originalPic release]; originalPic = nil;
    [inReplyToScreenname release]; inReplyToScreenname = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Parse Methods
+ (WeiboStatus *)statusWithDictionary:(NSDictionary *)dic{
    return [[[[self class] alloc] initWithDictionary:dic asRoot:YES] autorelease];
}
+ (WeiboStatus *)statusWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    WeiboStatus * status = [[self class] statusWithDictionary:dictionary];
    return status;
}
+ (NSArray *)statusesWithJSON:(NSString *)json{
    NSArray * dictionaries = [[json objectFromJSONString] objectForKey:@"statuses"];
    NSMutableArray * statuses = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboStatus * status = [WeiboStatus statusWithDictionary:dic];
        [statuses addObject:status];
    }
    return statuses;
}
+ (void)parseStatusesJSON:(NSString *)json callback:(WTCallback *)callback{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
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
				int l = [src length];
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
        
        NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic) {
			self.user = [WeiboUser userWithDictionary:userDic];
		}
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic) {
            WeiboStatus * retweeted = [[WeiboStatus alloc] _initWithDictionary:retweetedStatusDic];
			self.retweetedStatus = retweeted;
            [retweeted release];
		}
        
        WeiboStatus * statusThatHasImage = self;
        if (retweetedStatus) {
            statusThatHasImage = retweetedStatus;
        }
        self.thumbPicURL = statusThatHasImage.thumbnailPic;
        self.midPicURL = statusThatHasImage.middlePic;
        self.bigPicURL = statusThatHasImage.originalPic;
    }
    return self;
}

- (void)_setUpDisplayText{
    NSMutableString * string = [NSMutableString stringWithString:text];
    if (retweetedStatus) {
        [string appendFormat:@"\n\n// @%@:",retweetedStatus.user.name];
        [string appendString:retweetedStatus.text];
    }
    [self setDisplayTextWithString:string];
}

@end
