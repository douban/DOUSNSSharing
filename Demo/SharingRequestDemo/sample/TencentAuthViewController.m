//
//  TencentAuthViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "TencentAuthViewController.h"

#import "DemoContants.h"

@interface TencentAuthViewController ()

@end

@implementation TencentAuthViewController

- (DOUOAuth2VenderType)venderType
{
  return kDOUOAuth2VenderTencentWeibo;
}

- (NSString *)venderAPIKey
{
  return TENCENT_APPKEY;
}

- (NSString *)venderAPISecrect
{
  return TENCENT_SECRET;
}

- (NSString *)oauthRedirectURL
{
  return TENCENT_REDIRECT_URI;
}

@end
