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

@property(readonly, nonatomic) NSArray * links;
@property(readonly, nonatomic) NSArray * hashtags;
@property(readonly, nonatomic) NSArray * usernames;
@property(readonly, nonatomic) NSArray * activeRanges;

@end
