//
//  SinaweiboAuthViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "OAuthSampleBaseViewController.h"
#import "AppDelegate.h"

@interface OAuthSampleBaseViewController ()
@property (nonatomic, copy) OAuth2DidSucceed didSucceedBlock;
@property (nonatomic, copy) OAuth2DidFail didFailBlock;
@end

@implementation OAuthSampleBaseViewController {
  WKWebView *_authView;
}

- (void)dealloc
{
  [self.authorizationManager cancelAndClearBlocks];
}

- (void)setOAuth2DidSucceed:(OAuth2DidSucceed)didSucceedBlock
                    didFail:(OAuth2DidFail)didFailBlock
{
  self.didSucceedBlock = didSucceedBlock;
  self.didFailBlock = didFailBlock;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SSO"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(authorizeWithSSO:)];
  
  self.authorizationManager = [[DOUOAuth2AuthorizationManager alloc] initWithVenderAPIKey:[self venderAPIKey]
                                                                                   secret:[self venderAPISecrect]
                                                                               venderType:[self venderType]];
  
  [self authorizeWithOAuth2];
}

- (void)authorizeWithOAuth2
{
  __weak typeof(self) weakSelf = self;
  
  [self.authorizationManager setBlocksForDidSucceedBlock:^(DOUOAuth2Credential *credential) {
    weakSelf.didSucceedBlock(credential);
    [weakSelf.navigationController popViewControllerAnimated:YES];
  } didFailBlock:^(NSError *error) {
    NSLog(@"error : %@", error);
    weakSelf.didFailBlock();
    [weakSelf showAlertViewWithText:@"error"];
  } didCancelBlock:^(DOUOAuth2Credential *credential) {
    [weakSelf showAlertViewWithText:@"cancelled"];
  }];

  _authView = [[WKWebView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:_authView];
  [self.authorizationManager requestWithRedirectUri:[self oauthRedirectURL] scope:nil inWebView:_authView];
}

- (void)back:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)authorizeWithSSO:(id)sender
{
  [self showAlertViewWithText:@"Not support!"];
}

- (void)showAlertViewWithText:(NSString *)text
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:text preferredStyle:UIAlertControllerStyleAlert];
  [self presentViewController:alert animated:YES completion:nil];
}

- (DOUOAuth2VenderType)venderType
{
  @throw [NSException exceptionWithName:@"venderType" reason:@"venderType not implemented" userInfo:nil];
}

- (NSString *)venderAPIKey
{
  @throw [NSException exceptionWithName:@"venderAPIKey" reason:@"venderAPIKey not implemented" userInfo:nil];
}

- (NSString *)venderAPISecrect
{
  @throw [NSException exceptionWithName:@"venderAPISecrect" reason:@"venderAPISecrect not implemented" userInfo:nil];
}

- (NSString *)oauthRedirectURL
{
  @throw [NSException exceptionWithName:@"oauthRedirectURL" reason:@"oauthRedirectURL not implemented" userInfo:nil];
}

@end
