//
//  WeiboConstants.h
//  Weibo
//
//  Created by Wu Tian on 12-2-15.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

typedef unsigned long long WeiboStatusID;
typedef unsigned long long WeiboUserID;

typedef enum {
    WeiboGenderUnknow = 0,
    WeiboGenderMale,
    WeiboGenderFemale,
} WeiboGender;

#if NS_BLOCKS_AVAILABLE
typedef void (^WTBasicBlock)(void);
typedef void (^WTArrayBlock)(NSArray *array);
typedef void (^WTObjectBlock)(id object);
#endif

#define WeiboUnimplementedMethod NSLog(@"[Warning - Weibo SDK] A Unimplemented Method Has Been Called. In File:%s , Line:%d.", __FILE__, __LINE__);

#define OFFLINE_DEBUG_MODE NO

#define WEIBO_APIROOT_V1 @"http://api.t.sina.com.cn/"
#define WEIBO_APIROOT_V2 @"https://api.weibo.com/2/"
#define WEIBO_APIROOT_DEFAULT WEIBO_APIROOT_V2

#define kWeiboStatusDeleteNotification @"WeiboStatusDeleteNotification"

#define kWeiboStreamStatusChangedNotification @"WeiboStreamStatusChangedNotification"
#define kWeiboAccountDidUpdateNotification @"WeiboAccountDidUpdateNotification"
#define kWeiboAccountDidReceiveUnreadNotification @"WeiboAccountDidReceiveUnreadNotification" 
#define kWeiboAccessTokenExpriedNotification @"WeiboAccessTokenExpriedNotification"
#define kWeiboAccountAvatarDidUpdateNotification @"WeiboAccountAvatarDidUpdateNotification"
#define kWeiboHTTPRequestDidSendNotification @"WeiboHTTPRequestDidSendNotification"
#define kWeiboHTTPRequestDidCompleteNotification @"WeiboHTTPRequestDidCompleteNotification"

extern NSString * const WeiboObjectWithIdentifierWillDeallocNotification;
extern NSString * const WeiboObjectUserInfoUniqueIdentifierKey;

#define WEIBO_LINK_REGEX @"(?i)https?://[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*"
#define SHORT_LINK_REGEX @"(http://t.cn/)([a-zA-Z0-9]+)"
#define MENTION_REGEX @"@([\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]+)"
#define HASHTAG_REGEX @"#(.+?)#"
#define EMOTICON_REGEX @"\\[([^ \\[]*?)]"

enum {
	WeiboStatusesAddingTypePrepend,
    WeiboStatusesAddingTypeAppend,
    WeiboStatusesAddingTypeGap
};
typedef NSInteger WeiboStatusesAddingType;

enum {
    WeiboNotificationNone                   = 0,
    
    WeiboTweetNotificationMenubar           = 1 << 0,
    WeiboTweetNotificationBadge             = 1 << 1,
    WeiboTweetNotificationSystemCenter      = 1 << 2,

    WeiboMentionNotificationMenubar         = 1 << 3,
    WeiboMentionNotificationBadge           = 1 << 4,
    WeiboMentionNotificationSystemCenter    = 1 << 5,

    WeiboCommentNotificationMenubar         = 1 << 6,
    WeiboCommentNotificationBadge           = 1 << 7,
    WeiboCommentNotificationSystemCenter    = 1 << 8,

    WeiboDirectMessageNotificationMenubar   = 1 << 9,
    WeiboDirectMessageNotificationBadge     = 1 << 10,
    WeiboDirectMessageNotificationSystemCenter = 1 << 11,

    WeiboFollowerNotificationMenubar        = 1 << 12,
    WeiboFollowerNotificationBadge          = 1 << 13,
    WeiboFollowerNotificationSystemCenter    = 1 << 14,
    
    WeiboNotificationVersionSystemCenterIntegrated = 1 << 31,
    
    WeiboNotificationDefaults               = 0b0101101101101001 | WeiboNotificationVersionSystemCenterIntegrated,
};
typedef int64_t WeiboNotificationOptions;

enum {
    WeiboUnreadCountTypeStatus = 0,
	WeiboUnreadCountTypeComment = 1,
    WeiboUnreadCountTypeStatusMention = 2,
    WeiboUnreadCountTypeDirectMessage = 3,
    WeiboUnreadCountTypeFollower = 4,
    WeiboUnreadCountTypeCommentMention = 5
};
typedef NSUInteger WeiboUnreadCountType;


typedef NS_ENUM(NSInteger, WeiboUserVerifiedType)
{
    WeiboUserVerifiedTypeNone = -1,
    WeiboUserVerifiedTypeYellowMark = 0,
    WeiboUserVerifiedTypeEnterprise = 2,
    WeiboUserVerifiedTypeBlueMark = 3,
    WeiboUserVerifiedTypeWeiboGirl = 10,
    WeiboUserVerifiedTypeGrassroot = 220,
};

static NSString * WEIBO_CONSUMER_KEY = nil;
static NSString * WEIBO_CONSUMER_SECRET = nil;

#import "WeiboModelPersistence.h"

