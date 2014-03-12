//
//  WTActiveTextRanges.h
//  Weibo
//
//  Created by Wu Tian on 12-2-18.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTActiveTextRanges : NSObject {
    NSArray * links;
    NSArray * hashtags;
    NSArray * usernames;
    NSArray * activeRanges;
}

- (id)initWithString:(NSString *)string;

@property(readonly, nonatomic, strong) NSArray * links;
@property(readonly, nonatomic, strong) NSArray * hashtags;
@property(readonly, nonatomic, strong) NSArray * usernames;
@property(readonly, nonatomic, strong) NSArray * activeRanges;

@end
