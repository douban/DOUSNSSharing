//
//  SinaweiboAuthViewController.h
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubanSNSSharing.h"


typedef void (^OAuth2DidSucceed)(DOUOAuth2Credential * credential);
typedef void (^OAuth2DidFail)();

@interface OAuthSampleBaseViewController : UIViewController

@property (nonatomic, strong) DOUOAuth2AuthorizationManager * authorizationManager;

- (void)setOAuth2DidSucceed:(OAuth2DidSucceed)didSucceedBlock
                    didFail:(OAuth2DidFail)didFailBlock;

- (void)showAlertViewWithText:(NSString *)text;

- (DOUOAuth2VenderType)venderType;
- (NSString *)venderAPIKey;
- (NSString *)venderAPISecrect;
- (NSString *)oauthRedirectURL;
@end
