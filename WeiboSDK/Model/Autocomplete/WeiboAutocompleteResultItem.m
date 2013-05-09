//
//  WeiboAutocompleteResultItem.m
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboAutocompleteResultItem.h"

@implementation WeiboAutocompleteResultItem
@synthesize priority, autocompleteType, autocompleteAction, itemID;
@synthesize userInfo, autocompleteText, autocompleteSubtext, autocompleteImageURL;

- (NSString *)searchableSortableText{
    return nil;
}
- (void)dealloc{
    self.itemID = nil;
    self.autocompleteText = nil;
    self.autocompleteSubtext = nil;
    self.autocompleteImageURL = nil;
    self.userInfo = nil;
    [_derivedSearchableText release];
    [super dealloc];
}
- (BOOL)isEqual:(id)object{
    return NO;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@",self.autocompleteText];
}

@end
