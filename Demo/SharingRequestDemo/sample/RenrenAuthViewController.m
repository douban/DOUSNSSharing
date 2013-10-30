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
  return kAPP_ID;
}

- (NSString *)venderAPISecrect
{
  return kAPI_Secrect;
}

- (NSString *)oauthRedirectURL
{
  return kCALLBACK_URL;
}

@end
