//
//  WeiboListStream.m
//  Weibo
//
//  Created by Wutian on 13-7-27.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WeiboListStream.h"
#import "WeiboList.h"
#import "WeiboAPI+StatusMethods.h"

@implementation WeiboListStream

- (void)_loadNewer
{
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];
    [api listStatuses:self.list.listID sinceID:[self newestStatusID] maxID:0 count:[self hasData]?100:20 page:1];
}

- (void)_loadOlder
{
    WeiboAPI * api = [account authenticatedRequest:[self loadOlderResponseCallback]];
    
    WeiboStatusID oldestID = self.oldestStatusID;
    WeiboStatusID maxID = oldestID > 0 ? (oldestID - 1) : 0;
    [api listStatuses:self.list.listID sinceID:0 maxID:maxID count:100 page:1];
}

- (NSString *)autosaveName
{
    return [[super autosaveName] stringByAppendingFormat:@"list/%@.scrollPosition",self.list.name];
}

- (BOOL)appliesStatusFilter
{
    return YES;
}

+ (instancetype)objectWithPersistenceInfo:(id)info forAccount:(WeiboAccount *)account
{
    WeiboListStream * stream = [super objectWithPersistenceInfo:info forAccount:account];
    
    WeiboList * list = [[WeiboList new] autorelease];
    list.listID = info[@"listID"];
    list.name = info[@"name"];
    
    stream.list = list;
    
    return stream;
}

- (id)persistenceInfo
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.list.listID, @"listID", self.list.name, @"name", nil];
}

@end
