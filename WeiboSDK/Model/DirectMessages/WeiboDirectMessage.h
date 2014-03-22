//
//  WeiboDirectMessage.h
//  Weibo
//
//  Created by Wutian on 13-9-2.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboModel.h"
#import "WeiboUser.h"
#import "WeiboAttributedString.h"

typedef int64_t WeiboMessageID;

@interface WeiboDirectMessage : WeiboModel

@property (nonatomic, assign) WeiboMessageID messageID;
@property (nonatomic, assign) time_t date;
@property (nonatomic, copy) NSString * text;

@property (nonatomic, assign) WeiboUserID senderID;
@property (nonatomic, assign) WeiboUserID recipientID;


@property (nonatomic, strong) WeiboUser * sender;
@property (nonatomic, strong) WeiboUser * recipient;
@property (nonatomic, assign) BOOL read;

@property (nonatomic, strong, readonly) WeiboAttributedString * attributedString;

- (NSComparisonResult)compare:(WeiboDirectMessage *)object;

@end
