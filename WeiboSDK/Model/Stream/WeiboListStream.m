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
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];
    
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

@end
