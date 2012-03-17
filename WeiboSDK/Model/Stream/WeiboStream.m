//
//  WeiboStream.m
//  Weibo
//
//  Created by Wu Tian on 12-2-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboStream.h"

@implementation WeiboStream
@synthesize lastDismissTime, statuses, savedCellIndex, savedRelativeOffset;
@synthesize delegate = _delegate;

- (BOOL)canLoadNewer{
    return YES;
}

- (void)loadNewer{
    // subclass should implement
}
- (void)loadOlder{
    // subclass should implement
}
- (void)retryLoadOlder{
    
}
- (void)fillInGap:(id)arg1{
    // subclass should implement
}
- (BOOL)supportsFillingInGaps{
    return NO;
}
- (BOOL)hasData{
    return [[self statuses] count] > 0;
}
- (void)didLoadOlder{
    // subclass should implement
}
- (NSString *)autosaveName{
    return nil;
}
- (NSUInteger)statuseIndexByID:(WeiboStatusID)theID{
    return 0;
}
- (BOOL)isStreamEnded{
    return NO;
}

@end
