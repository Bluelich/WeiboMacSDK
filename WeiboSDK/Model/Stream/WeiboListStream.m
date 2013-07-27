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

- (void)_loaderNewer
{
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];
    
}

- (void)_loadOlder
{
    WeiboAPI * api = [account authenticatedRequest:[self loadNewerResponseCallback]];

}

- (NSString *)autosaveName
{
    return [[super autosaveName] stringByAppendingFormat:@"list/%@.scrollPosition",self.list.name];
}

@end
