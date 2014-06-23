//
//  DOUVenderUserInfo+Renren.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderUserInfo+Renren.h"


static NSString *const kDOUVenderRenrenPostKeyUserID = @"id";
static NSString *const kDOUVenderRenrenPostKeyScreenName = @"name";
static NSString *const kDOUVenderRenrenPostKeyName = @"name";

@implementation DOUVenderUserInfo (Renren)


/*
 Map keys defined at http://wiki.dev.renren.com/wiki/Users.getInfo
 */
- (void)setUserInfoFromJSONDicForRenren:(NSDictionary *)jsonDic
{
  @try {
    [self checkKeysInDicForRenren:jsonDic];
    id object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyUserID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.userID = [object stringValue];
    } else {
      self.userID = [object description];
    }
    
    object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyScreenName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.screeNname = object;
    }
    
    object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.name = object;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForRenren:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyUserID];
  NSAssert(object != nil, @"should have user id");
  object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyScreenName];
  NSAssert(object != nil, @"should have user screen name");
  object = [jsonDic objectForKey:kDOUVenderRenrenPostKeyName];
  NSAssert(object != nil, @"should have name");
}

@end
