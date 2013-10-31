//
//  RenrenAuthViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "RenrenAuthViewController.h"

#import "DemoContants.h"

@interface RenrenAuthViewController ()

@end

@implementation RenrenAuthViewController

- (DOUOAuth2VenderType)venderType
{
  return kDOUOAuth2VenderRenren;
}

- (NSString *)venderAPIKey
{
  return RENREN_TEST_APIKEY;
}

- (NSString *)venderAPISecrect
{
  return RENREN_TEST_SECRECT;
}

- (NSString *)oauthRedirectURL
{
  return RENREN_TEST_CALLBACK_URL;
}

@end
