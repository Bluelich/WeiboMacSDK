//
//  WeiboUserMentionSuggestion.h
//  Weibo
//
//  Created by Wutian on 13-12-21.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboUser.h"

@interface WeiboUserMentionSuggestion : NSObject

@property (nonatomic, assign) WeiboUserID userID;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * remark;

+ (NSArray *)suggestionsWithJSONArray:(NSArray *)array;

@end
