//
//  WeiboAutocompleteResultItem.h
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    WeiboAutocompleteTypeUser       = 1,
    WeiboAutocompleteTypeHashtag    = 2,
    WeiboAutocompleteTypeCustom     = 99,
};
typedef NSInteger WeiboAutocompleteType;

@protocol WeiboAutoCompleteResultItem <NSObject>
- (NSString *)searchableSortableText;
@property(nonatomic) NSInteger priority;
@property(nonatomic) WeiboAutocompleteType autocompleteType;
@property(nonatomic) long long autocompleteAction;
@property(retain, nonatomic) NSString *itemID;
@property(retain, nonatomic) id userInfo;
@property(retain, nonatomic) NSURL *autocompleteImageURL;
@property(retain, nonatomic) NSString *autocompleteSubtext;
@property(retain, nonatomic) NSString *autocompleteText;
@end

@interface WeiboAutocompleteResultItem : NSObject <WeiboAutoCompleteResultItem> {
    NSString *autocompleteText;
    NSString *autocompleteSubtext;
    NSURL *autocompleteImageURL;
    id userInfo;
    NSString *itemID;
    long long autocompleteAction;
    WeiboAutocompleteType autocompleteType;
    NSInteger priority;
    NSString *_derivedSearchableText;
}

@property (nonatomic, assign) NSInteger tag;

@end
