//
//  AppGlobal.m
//  SharingRequestDemo
//
//
//

#import "AppGlobal.h"

static AppGlobal *instance = nil;

@implementation AppGlobal

- (NSArray *)allCredentials
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:8];
  if (self.sinaWeibo) {
    [array addObject:self.sinaWeibo];
  }
  if (self.renren) {
    [array addObject:self.renren];
  }
  if (self.tencentWeibo) {
    [array addObject:self.tencentWeibo];
  }
  return array;
}

- (DOUOAuth2Credential *)credentialByVenderType:(DOUOAuth2VenderType)venderType
{
  if (venderType == kDOUOAuth2VenderSinaWeibo) {
    return self.sinaWeibo;
  } else if (venderType == kDOUOAuth2VenderRenren) {
    return self.renren;
  } else if (venderType == kDOUOAuth2VenderTencentWeibo) {
    return self.tencentWeibo;
  } else {
    return nil;
  }
}

#pragma mark -  singleton methods
+ (AppGlobal *)sharedInstance
{
  static dispatch_once_t onceToken = 0L;
  dispatch_once(&onceToken, ^{
    instance = [[super allocWithZone:NULL] init];
  });
  return instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
  return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

@end
