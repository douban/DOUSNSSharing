//
//  SinaweiboAuthViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "SinaweiboAuthViewController.h"

#import "AppDelegate.h"
#import "DemoContants.h"


@implementation SinaweiboAuthViewController

- (DOUOAuth2VenderType)venderType
{
  return kDOUOAuth2VenderSinaWeibo;
}

- (NSString *)venderAPIKey
{
  return SINA_APPKEY;
}

- (NSString *)venderAPISecrect
{
  return SINA_SECRET;
}

- (NSString *)oauthRedirectURL
{
  return SINA_REDIRECT_URI;
}

@end
