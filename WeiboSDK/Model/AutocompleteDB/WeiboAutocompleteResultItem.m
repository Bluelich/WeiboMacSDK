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

- (NSString *)searchableSortableText
{
    return nil;
}
- (NSUInteger)hash
{
    return self.itemID.hash;
}
- (BOOL)isEqual:(WeiboAutocompleteResultItem *)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[WeiboAutocompleteResultItem class]]) return NO;
    return [self.itemID isEqual:object.itemID];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@",self.autocompleteText];
}

@end
