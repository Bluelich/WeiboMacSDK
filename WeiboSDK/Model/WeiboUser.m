//
//  WeiboUser.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUser.h"
#import "WeiboStatus.h"
#import "WTCallback.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"

@implementation WeiboUser
@synthesize userID, screenName, name, province, city, location, description;
@synthesize url, profileImageUrl, domain, gender, followersCount, friendsCount;
@synthesize statusesCount, favouritesCount, createAt, following, verified, status;
@synthesize cacheTime, followMe, profileLargeImageUrl;

- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        self.userID = [decoder decodeInt64ForKey:@"user-id"];
        self.screenName = [decoder decodeObjectForKey:@"screenname"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.province = [decoder decodeObjectForKey:@"province"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.profileImageUrl = [decoder decodeObjectForKey:@"profile-image-url"];
        self.profileLargeImageUrl = [decoder decodeObjectForKey:@"profile-large-image-url"];
        self.domain = [decoder decodeObjectForKey:@"domain"];
        self.gender = [decoder decodeIntegerForKey:@"gender"];
        self.followersCount = [decoder decodeIntForKey:@"followers-count"];
        self.friendsCount = [decoder decodeIntForKey:@"friends-count"];
        self.statusesCount = [decoder decodeIntForKey:@"statuses-count"];
        self.favouritesCount = [decoder decodeIntForKey:@"favourites-count"];
        self.createAt = [decoder decodeIntForKey:@"create-at"];
        self.following = [decoder decodeBoolForKey:@"following"];
        self.followMe = [decoder decodeBoolForKey:@"follow-me"];
        self.verified = [decoder decodeBoolForKey:@"verified"];
        //self.status = [decoder decodeObjectForKey:@"status"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt64:userID forKey:@"user-id"];
    [encoder encodeObject:screenName forKey:@"screenname"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:province forKey:@"province"];
    [encoder encodeObject:city forKey:@"city"];
    [encoder encodeObject:location forKey:@"location"];
    [encoder encodeObject:description forKey:@"description"];
    [encoder encodeObject:url forKey:@"url"];
    [encoder encodeObject:profileImageUrl forKey:@"profile-image-url"];
    [encoder encodeObject:profileLargeImageUrl forKey:@"profile-large-image-url"];
    [encoder encodeObject:domain forKey:@"domain"];
    //[encoder encodeObject:status forKey:@"status"];
    [encoder encodeInteger:gender forKey:@"gender"];
    [encoder encodeInt:followersCount forKey:@"followers-count"];
    [encoder encodeInt:friendsCount forKey:@"friends-count"];
    [encoder encodeInt:statusesCount forKey:@"statuses-count"];
    [encoder encodeInt:favouritesCount forKey:@"favourites-count"];
    [encoder encodeInt:(int)createAt forKey:@"create-at"];
    [encoder encodeBool:following forKey:@"following"];
    [encoder encodeBool:followMe forKey:@"follow-me"];
    [encoder encodeBool:verified forKey:@"verified"];
}

- (void)dealloc{
    [screenName release]; screenName = nil;
    [name release]; name = nil;
    [province release]; province = nil;
    [city release]; city = nil;
    [location release]; location = nil;
    [description release]; description = nil;
    [url release]; url = nil;
    [profileImageUrl release]; profileImageUrl = nil;
    [profileLargeImageUrl release]; profileLargeImageUrl = nil;
    [domain release]; domain = nil;
    [status release]; status = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Parse Methods
+ (WeiboUser *)userWithDictionary:(NSDictionary *)dic{
    return [[[WeiboUser alloc] initWithDictionary:dic] autorelease];
}
+ (WeiboUser *)userWithJSON:(NSString *)json{
    NSDictionary * dictionary = [json objectFromJSONString];
    return [WeiboUser userWithDictionary:dictionary];
}
+ (NSArray *)usersWithJSON:(NSString *)json{
    NSArray * dictionaries = [json objectFromJSONString];
    NSMutableArray * users = [NSMutableArray array];
    for (NSDictionary * dic in dictionaries) {
        WeiboUser * user = [WeiboUser userWithDictionary:dic];
        [users addObject:user];
    }
    return users;
}
+ (void)parseUserJSON:(NSString *)json onComplete:(WTObjectBlock)block{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        WeiboUser * user = [self userWithJSON:json];
        [json release];
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(user);
        });
    });
}
+ (void)parseUsersJSON:(NSString *)json onComplete:(WTArrayBlock)block{
    [json retain];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSArray * users = [self usersWithJSON:json];
        [json release];
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(users);
        });
    });
}
+ (void)parseUserJSON:(NSString *)json callback:(WTCallback *)callback{
    [WeiboUser parseUserJSON:json onComplete:^(id object) {
        [callback invoke:object];
    }];
}
+ (void)parseUsersJSON:(NSString *)json callback:(WTCallback *)callback{
    [WeiboUser parseUsersJSON:json onComplete:^(NSArray * array) {
        [callback invoke:array];
    }];
}
- (WeiboUser *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.userID = [dic longlongForKey:@"id" defaultValue:0];
        self.screenName = [dic stringForKey:@"screen_name" defaultValue:@""];
        self.name = [dic stringForKey:@"name" defaultValue:@""];
        self.province = @""; // Not implemented yet.
        self.city = @""; // Not implemented yet.
        self.location = [dic stringForKey:@"location" defaultValue:@""];
        self.description = [dic stringForKey:@"description" defaultValue:@""];
        self.url = [dic stringForKey:@"url" defaultValue:@""];
        self.profileImageUrl = [dic stringForKey:@"profile_image_url" defaultValue:@""];
        self.profileLargeImageUrl = [dic stringForKey:@"avatar_large" defaultValue:nil];
        self.domain = [dic stringForKey:@"domain" defaultValue:@""];
        
        NSString * genderChar = [dic objectForKey:@"gender"];
        if ([genderChar isEqualToString:@"m"])      self.gender = WeiboGenderMale;
        else if ([genderChar isEqualToString:@"f"]) self.gender = WeiboGenderFemale;
        else                                        self.gender = WeiboGenderUnknow;
        
        self.followersCount = [dic intForKey:@"followers_count" defaultValue:0];
        self.friendsCount = [dic intForKey:@"friends_count" defaultValue:0];
        self.statusesCount = [dic intForKey:@"statuses_count" defaultValue:0];
        self.favouritesCount = [dic intForKey:@"favourites_count" defaultValue:0];
        self.createAt = [dic timeForKey:@"create_at" defaultValue:0];
        self.following = [dic boolForKey:@"following" defaultValue:NO];
        self.followMe = [dic boolForKey:@"follow_me" defaultValue:NO];
        self.verified = [dic boolForKey:@"verified" defaultValue:NO];
        
        NSDictionary * statusDic = [dic objectForKey:@"status"];
        if (statusDic) {
            self.status = [WeiboStatus statusWithDictionary:statusDic];
        }
    }
    return self;
}

@end
