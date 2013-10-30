//
//  DOUVenderPost+Renren.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderPost+Renren.h"
#import "NSDate+ExpiresIn.h"


@implementation DOUVenderPost (Renren)

- (void)setValuesFromJSONStrForRenren:(NSString *)jsonStr
{
  NSDictionary *jsonDic = [DOUSNSSharingUtil objectFromJSONString:jsonStr];
  @try {
    [self checkKeysInDicForRenren:jsonDic];
    id object = [jsonDic objectForKey:@"post_id"];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.postid = [object stringValue];
    } else {
      self.postid = [object description];
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForRenren:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:@"post_id"];
  NSAssert(object != nil, @"should have post id");
}

@end
