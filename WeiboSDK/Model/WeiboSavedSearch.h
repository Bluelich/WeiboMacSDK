//
//  WeiboSavedSearch.h
//  Weibo
//
//  Created by Wutian on 13-12-25.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboSavedSearch : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString * keyword;

@end
