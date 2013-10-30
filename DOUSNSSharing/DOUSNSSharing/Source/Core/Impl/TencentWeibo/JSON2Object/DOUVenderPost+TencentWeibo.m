//
//  DOUVenderPost+TencentWeibo.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderPost+TencentWeibo.h"
#import "NSDate+ExpiresIn.h"


static NSString *const kDOUVenderTencentWeiboPostKeyID = @"id";
static NSString *const kDOUVenderTencentWeiboPostKeyCreatedAt = @"timestamp";

/*
 
 消息格式 ： http://wiki.open.t.qq.com/index.php/API%E6%96%87%E6%A1%A3/%E5%BE%AE%E5%8D%9A%E6%8E%A5%E5%8F%A3/%E5%8F%91%E8%A1%A8%E4%B8%80%E6%9D%A1%E5%BE%AE%E5%8D%9A%E4%BF%A1%E6%81%AF
 */

@implementation DOUVenderPost (TencentWeibo)

- (void)setValuesFromJSONStrForTencentWeibo:(NSString *)jsonStr
{
  NSDictionary *jsonDic = [DOUSNSSharingUtil objectFromJSONString:jsonStr];
  @try {
    [self checkKeysInDicForTencentWeibo:jsonDic];
    jsonDic = [jsonDic objectForKey:@"data"];
    id object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.postid = [object stringValue];
    } else {
      self.postid = [object description];
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForTencentWeibo:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:kDOUVenderTencentWeiboPostKeyID];
  NSAssert(object != nil, @"should have post id");
}

@end
