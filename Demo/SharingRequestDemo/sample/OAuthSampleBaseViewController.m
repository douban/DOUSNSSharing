//
//  SinaweiboAuthViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "OAuthSampleBaseViewController.h"
#import "AppDelegate.h"

@interface OAuthSampleBaseViewController ()
@property (nonatomic, copy) OAuth2DidSucceed didSucceedBlock;
@property (nonatomic, copy) OAuth2DidFail didFailBlock;
@end

@implementation OAuthSampleBaseViewController {
  UIView *_authView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
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
  __unsafe_unretained OAuthSampleBaseViewController *_selfWeakRef = self;
  
  [self.authorizationManager setBlocksForDidSucceedBlock:^(DOUOAuth2Credential *credential) {
    _selfWeakRef.didSucceedBlock(credential);
    [_selfWeakRef.navigationController popViewControllerAnimated:YES];
  } didFailBlock:^(NSError *error) {
    NSLog(@"error : %@", error);
    _selfWeakRef.didFailBlock();
    [_selfWeakRef showAlertViewWithText:@"error"];
  } didCancelBlock:^(DOUOAuth2Credential *credential) {
    [_selfWeakRef showAlertViewWithText:@"cancelled"];
  }];
  UIView *oauthView = [self.authorizationManager requestWithRedirectUri:[self oauthRedirectURL]
                                                                  scope:nil];
  [self.view addSubview:oauthView];
  oauthView.frame = self.view.bounds;
  _authView = oauthView;
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
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:text delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
  [alert show];
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
