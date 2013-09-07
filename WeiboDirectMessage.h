//
//  WeiboDirectMessage.h
//  Weibo
//
//  Created by Wutian on 13-9-2.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboUser.h"

typedef int64_t WeiboMessageID;

@interface WeiboDirectMessage : NSObject <NSCoding>

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, assign) WeiboMessageID messageID;
@property (nonatomic, assign) time_t date;
@property (nonatomic, copy) NSString * text;

@property (nonatomic, assign) WeiboUserID senderID;
@property (nonatomic, assign) WeiboUserID recipientID;


@property (nonatomic, retain) WeiboUser * sender;
@property (nonatomic, retain) WeiboUser * recipient;
@property (nonatomic, assign) BOOL read;

- (NSComparisonResult)compare:(WeiboDirectMessage *)object;

@end
