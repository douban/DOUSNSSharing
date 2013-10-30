//
//  DOUVenderPost+SinaWeibo.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderPost+SinaWeibo.h"
#import "NSDate+ExpiresIn.h"


static NSString *const kDOUVenderSinaWeiboPostKeyID = @"id";
static NSString *const kDOUVenderSinaWeiboPostKeyText = @"text";
static NSString *const kDOUVenderSinaWeiboPostKeyCreatedAt = @"created_at";

@implementation DOUVenderPost (SinaWeibo)

- (void)setValuesFromJSONStrForSinaWeibo:(NSString *)jsonStr
{
  NSDictionary *jsonDic = [DOUSNSSharingUtil objectFromJSONString:jsonStr];
  [self checkKeysInDicForSinaWeibo:jsonDic];
  @try {
    id object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyID];
    if (IS_INSTANCE_OF(object, NSNumber)) {
      self.postid = [object stringValue];
    } else {
      self.postid = [object description];
    }
    
    object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyText];
    if (IS_INSTANCE_OF(object, NSString)) {
      self.text = object;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
  }
}

- (void)checkKeysInDicForSinaWeibo:(NSDictionary *)jsonDic
{
  NSAssert(jsonDic != nil, @"jsonDic should not be nil");
  
  id object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyID];
  NSAssert(object != nil, @"should have post id");
  object = [jsonDic objectForKey:kDOUVenderSinaWeiboPostKeyText];
  NSAssert(object != nil, @"should have post text");
}

@end
