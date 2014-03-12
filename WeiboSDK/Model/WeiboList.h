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

@property (nonatomic, strong) NSString * listID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * mode;
@property (nonatomic, assign) NSInteger memberCount;
@property (nonatomic, strong) NSString * description;

@property (nonatomic, unsafe_unretained) WeiboAccount * account;
@property (nonatomic, strong, readonly) WeiboListStream * stream;

+ (id)listWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isPrivate;

@end
