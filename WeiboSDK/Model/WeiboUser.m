//
//  WeiboUser.m
//  Weibo
//
//  Created by Wu Tian on 12-2-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboUser.h"
#import "WeiboStatus.h"
#import "WeiboCallback.h"
#import "WeiboAccount.h"
#import "NSDictionary+WeiboAdditions.h"
#import "JSONKit.h"

@implementation WeiboUser
@synthesize userID, screenName, name, province, city, location, description;
@synthesize url, profileImageUrl, domain, gender, followersCount, friendsCount;
@synthesize statusesCount, favouritesCount, createAt, following, status;
@synthesize cacheTime, followMe, profileLargeImageUrl;

- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        self.userID = (WeiboUserID)[decoder decodeInt64ForKey:@"user-id"];
        self.screenName = [decoder decodeObjectForKey:@"screenname"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.remark = [decoder decodeObjectForKey:@"remark"];
        self.province = [decoder decodeObjectForKey:@"province"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.profileImageUrl = [decoder decodeObjectForKey:@"profile-image-url"];
        self.profileLargeImageUrl = [decoder decodeObjectForKey:@"profile-large-image-url"];
        self.domain = [decoder decodeObjectForKey:@"domain"];
        self.gender = (WeiboGender)[decoder decodeIntegerForKey:@"gender"];
        self.followersCount = [decoder decodeIntForKey:@"followers-count"];
        self.friendsCount = [decoder decodeIntForKey:@"friends-count"];
        self.statusesCount = [decoder decodeIntForKey:@"statuses-count"];
        self.favouritesCount = [decoder decodeIntForKey:@"favourites-count"];
        self.createAt = [decoder decodeIntForKey:@"create-at"];
        self.following = [decoder decodeBoolForKey:@"following"];
        self.followMe = [decoder decodeBoolForKey:@"follow-me"];
        //self.verified = [decoder decodeBoolForKey:@"verified"];
        self.verifiedType = [decoder decodeIntegerForKey:@"verified-type"];
        self.verifiedReason = [decoder decodeObjectForKey:@"verified-reason"];
        //self.status = [decoder decodeObjectForKey:@"status"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt64:(int64_t)userID forKey:@"user-id"];
    [encoder encodeObject:screenName forKey:@"screenname"];
    [encoder encodeObject:_remark forKey:@"remark"];
    [encoder encodeObject:profileImageUrl forKey:@"profile-image-url"];
    [encoder encodeObject:profileLargeImageUrl forKey:@"profile-large-image-url"];
    
    if (!self.simplifiedCoding)
    {
        [encoder encodeObject:name forKey:@"name"];
        [encoder encodeObject:province forKey:@"province"];
        [encoder encodeObject:city forKey:@"city"];
        [encoder encodeObject:location forKey:@"location"];
        [encoder encodeObject:description forKey:@"description"];
        [encoder encodeObject:url forKey:@"url"];
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
        //[encoder encodeBool:verified forKey:@"verified"];
        [encoder encodeInteger:_verifiedType forKey:@"verified-type"];
        [encoder encodeObject:_verifiedReason forKey:@"verified-reason"];
    }
}

- (void)dealloc
{
    _remark = nil;
}

#pragma mark -
#pragma mark Parse Methods

+ (NSString *)defaultJSONArrayRootKey
{
    return @"users";
}
+ (NSString *)defaultJSONObjectRootKey
{
    return @"user";
}

- (BOOL)updateWithJSONDictionary:(NSDictionary *)dic
{
    if ([super updateWithJSONDictionary:dic])
    {
        self.userID = (WeiboUserID)[dic longlongForKey:@"id" defaultValue:0];
        self.screenName = [dic stringForKey:@"screen_name" defaultValue:@""];
        self.name = [dic stringForKey:@"name" defaultValue:@""];
        self.remark = [dic stringForKey:@"remark" defaultValue:nil];
        
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
        //self.verified = [dic boolForKey:@"verified" defaultValue:NO];
        self.verifiedType = [dic intForKey:@"verified_type" defaultValue:-1];
        self.verifiedReason = [dic stringForKey:@"verified_reason" defaultValue:nil];
        
        NSDictionary * statusDic = [dic objectForKey:@"status"];
        if (statusDic) {
            self.status = [WeiboStatus objectWithJSONObject:statusDic account:self.account];
        }
        
        return YES;
    }
    return NO;
}

- (BOOL)verified
{
    return (self.verifiedType == WeiboUserVerifiedTypeBlueMark ||
            self.verifiedType == WeiboUserVerifiedTypeYellowMark ||
            self.verifiedType == WeiboUserVerifiedTypeEnterprise);
}

- (BOOL)isDaren
{
    return (self.verifiedType == WeiboUserVerifiedTypeGrassroot ||
            self.verifiedType == WeiboUserVerifiedTypeWeiboGirl);
}

- (BOOL)isMine
{
    return [self.account.user isEqual:self];
}

- (NSUInteger)hash
{
    return self.userID;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    return ([object userID] == [self userID]);
}

@end
