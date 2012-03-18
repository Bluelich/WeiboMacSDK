//
//  WeiboAutocompleteResultItem.h
//  Weibo
//
//  Created by Wu Tian on 12-3-17.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTAutoCompleteResultItem.h"

@interface WeiboAutocompleteResultItem : NSObject <WTAutoCompleteResultItem> {
    NSString *autocompleteText;
    NSString *autocompleteSubtext;
    NSURL *autocompleteImageURL;
    id userInfo;
    NSString *itemID;
    long long autocompleteAction;
    int autocompleteType;
    NSInteger priority;
    NSString *_derivedSearchableText;
}



@end
