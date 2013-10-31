//
//  DoubanAuthViewController.m
//  SharingRequestDemo
//
//

#import "DoubanAuthViewController.h"

#import "AppDelegate.h"
#import "DemoContants.h"


@interface DoubanAuthViewController ()

@end

@implementation DoubanAuthViewController

- (DOUOAuth2VenderType)venderType
{
  return kDOUOAuth2VenderDouban;
}

- (NSString *)venderAPIKey
{
  return DOUBAN_APPKEY;
}

- (NSString *)venderAPISecrect
{
  return DOUBAN_SECRET;
}

- (NSString *)oauthRedirectURL
{
  return DOUBAN_REDIRECT_URI;
}

@end
