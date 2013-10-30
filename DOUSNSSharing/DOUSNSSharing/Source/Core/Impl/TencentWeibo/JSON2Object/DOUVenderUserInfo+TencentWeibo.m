//
//  DOUVenderUserInfo+TencentWeibo.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderUserInfo+TencentWeibo.h"


static NSString *const kDOUVenderTencentWeiboPostKeyUserID = @"openid";
static NSString *const kDOUVenderTencentWeiboPostKeyScreenName = @"name";
static NSString *const kDOUVenderTencentWeiboPostKeyName = @"nick";

/*
 数据定义 ： http://wiki.open.t.qq.com/index.php/API%E6%96%87%E6%A1%A3/%E5%B8%90%E6%88%B7%E6%8E%A5%E5%8F%A3/%E8%8E%B7%E5%8F%96%E6%89%B9%E9%87%8F%E7%94%A8%E6%88%B7%E7%9A%84%E4%B8%AA%E4%BA%BA%E8%B5%84%E6%96%99
 */

@implementation DOUVenderUserInfo (TencentWeibo)

- (void)setValuesFromJSONStrForTencentWeibo:(NSString *)jsonStr
{
  NSDictionary *jsonDic = [DOUSNSSharingUtil objectFromJSONString:jsonStr];
  @try {
    jsonDic = [jsonDic objectForKey:@"data"];
    [self checkKeysInDicForTencentWeibo:jsonDic];
    id object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyUserID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.userID = [object stringValue];
    } else {
      self.userID = [object description];
    }
    
    object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyScreenName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.screeNname = object;
    }
    
    object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyName];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.name = object;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForTencentWeibo:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyUserID];
  NSAssert(object != nil, @"should have user id");
  object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyScreenName];
  NSAssert(object != nil, @"should have user screen name");
  object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyName];
  NSAssert(object != nil, @"should have name");
}

@end
