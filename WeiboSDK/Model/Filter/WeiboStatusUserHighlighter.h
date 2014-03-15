//
//  WeiboStatusUserHighlighter.h
//  Weibo
//
//  Created by Wutian on 13-8-3.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboStatusUserFilter.h"

@interface WeiboStatusUserHighlighter : WeiboStatusUserFilter

@property (nonatomic, assign) BOOL highlightPosts;
@property (nonatomic, assign) BOOL highlightMentions;

@end
