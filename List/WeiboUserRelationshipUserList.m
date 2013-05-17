//
//  WeiboUserRelationshipUserList.m
//  Weibo
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboUserRelationshipUserList.h"
#import "LocalAutocompleteDB.h"

@implementation WeiboUserRelationshipUserList

- (void)didAddUsers:(NSArray *)users prepend:(BOOL)prepend
{
    [super didAddUsers:users prepend:prepend];
    
    [[LocalAutocompleteDB sharedAutocompleteDB] addUsers:users];
}

@end
