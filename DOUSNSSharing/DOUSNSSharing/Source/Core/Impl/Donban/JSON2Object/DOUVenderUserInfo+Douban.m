//
//  DOUVenderUserInfo+Douban.m
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.

#import "DOUVenderUserInfo+Douban.h"

static NSString *const kDOUVenderDoubanPostKeyUserID = @"douban_user_id";
static NSString *const kDOUVenderDoubanPostKeyScreenName = @"douban_user_name";

@implementation DOUVenderUserInfo (Douban)

- (void)setUserInfoFromJSONDicForDouban:(NSDictionary *)jsonDic
{
  @try {
    [self checkKeysInDicForDouban:jsonDic];
    id object = [jsonDic objectForKey:kDOUVenderDoubanPostKeyUserID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.userID = [object stringValue];
    } else {
      self.userID = [object description];
    }
    
    object = [jsonDic objectForKey:kDOUVenderDoubanPostKeyScreenName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.screeNname = object;
      self.name = object;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForDouban:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  id object = [jsonDic objectForKey:kDOUVenderDoubanPostKeyUserID];
  NSAssert(object != nil, @"should have user id");
  object = [jsonDic objectForKey:kDOUVenderDoubanPostKeyScreenName];
  NSAssert(object != nil, @"should have user screen name");
}

@end
