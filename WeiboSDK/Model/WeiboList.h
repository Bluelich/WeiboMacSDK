//
//  WeiboList.h
//  Weibo
//
//  Created by Wutian on 13-7-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboListStream.h"

@interface WeiboList : NSObject

@property (nonatomic, retain) NSString * listID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, assign) NSInteger memberCount;
@property (nonatomic, retain) NSString * description;

@property (nonatomic, assign) WeiboAccount * account;
@property (nonatomic, retain, readonly) WeiboListStream * stream;

+ (id)listWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isPrivate;

@end
