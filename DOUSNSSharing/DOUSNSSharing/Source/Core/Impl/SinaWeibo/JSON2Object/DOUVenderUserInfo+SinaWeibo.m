//
//  DOUVenderUserInfo+SinaWeibo.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderUserInfo+SinaWeibo.h"


static NSString *const kDOUVenderSinaWeiboPostKeyUserID = @"id";
static NSString *const kDOUVenderSinaWeiboPostKeyScreenName = @"screen_name";
static NSString *const kDOUVenderSinaWeiboPostKeyName = @"name";

@implementation DOUVenderUserInfo (SinaWeibo)

- (void)setValuesFromJSONStrForSinaWeibo:(NSString *)jsonStr
{
  NSDictionary *jsonDic = [DOUSNSSharingUtil objectFromJSONString:jsonStr];
  [self checkKeysInDicForSinaWeibo:jsonDic];
  @try {
    id object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyUserID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.userID = [object stringValue];
    } else {
      self.userID = [object description];
    }
    
    object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyScreenName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.screeNname = object;
    }
    
    object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.name = object;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForSinaWeibo:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyUserID];
  NSAssert(object != nil, @"should have user id");
  object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyScreenName];
  NSAssert(object != nil, @"should have user screen name");
  object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyName];
  NSAssert(object != nil, @"should have name");
}

@end
