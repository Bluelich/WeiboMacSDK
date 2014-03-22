//
//  WeiboStatusUserHighlighter.m
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusUserHighlighter.h"
#import "WeiboBaseStatus.h"
#import "WeiboUser.h"

@implementation WeiboStatusUserHighlighter

- (id)init
{
    if (self = [super init])
    {
        self.highlightMentions = NO;
        self.highlightPosts = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.highlightPosts = YES;
    }
    return self;
}

- (BOOL)validateStatus:(WeiboBaseStatus *)status
{
    if (self.highlightPosts && [super validateStatus:status])
    {
        status.isSpecial = YES;
    }
    else if (self.highlightMentions)
    {
        NSString * string = status.attributedString.string;
        
        [status.attributedString enumerateActiveRanges:^(WeiboAttributedStringRangeFlavor rangeFlavor, NSRange range, BOOL *stop) {
            if (rangeFlavor == WeiboAttributedStringRangeFlavorUsername)
            {
                if ([[string substringWithRange:range] hasSuffix:self.screenname])
                {
                    status.isSpecial = YES;
                    *stop = YES;
                }
            }
        }];
    }
    
    return NO;
}

- (NSString *)title
{
    return self.screenname;
}

@end
