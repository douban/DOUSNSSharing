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
  return SINA_DOUBANFM_APPKEY;
}

- (NSString *)venderAPISecrect
{
  return SINA_DOUBANFM_SECRET;
}

- (NSString *)oauthRedirectURL
{
  return SINA_DOUBANFM_REDIRECT_URI;
}

@end
