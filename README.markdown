豆瓣第三方认证和分享库 - DoubanSNSSharing
----------------------------

#### 功能概要说明
这是一个提供第三方认证和分享的iOS公共库。

v2.x 版本目前已有功能：

| Vender  | OAuth2认证 | SSO OAuth2认证 |分享      |
| --------| --------- | --------------| -------- |
| 豆瓣 |    支持    |    不支持      | 支持      |
| 新浪微博 |    支持    |    不支持      | 支持      |
| 腾讯微博 |    支持    |    不支持      | 支持      |
|  人人   |    支持    |    不支持      | 支持      |

#### 版本说明
当前的代码为v2.x版本

#### 开发计划

* 支持SSO认证方式的方式获取Access Token 
* 加入更多的OAuth认证和分享实现，比如QQ Zone，
* [待定]支持iOS内置的分享渠道。

#### 使用 CocoaPods
编辑 Podfile：

    pod 'DOUSNSSharing'

#### 使用方式

##### 使用认证的功能
详细可以查看Demo中的OAuthSampleBaseViewController

    self.authorizationManager = [[DOUOAuth2AuthorizationManager alloc] initWithVenderAPIKey:[self venderAPIKey]
                                                                                     secret:[self venderAPISecrect]
                                                                                 venderType:[self venderType]];

    [self.authorizationManager setBlocksForDidSucceedBlock:^(DOUOAuth2Credential *credential) {
      // TODO
    } didFailBlock:^(NSError *error) {
      // TODO
    } didCancelBlock:^(DOUOAuth2Credential *credential) {
      // TODO
    }];
    UIView *oauthView = [self.authorizationManager requestWithRedirectUri:[self oauthRedirectURL]
                                                                    scope:nil];
    [self.view addSubview:oauthView];

##### 使用分享功能
详细可以查看Demo中的AuthorizationSamplesViewController

    self.requestManager = [[DOUVenderAPIRequestManager alloc] initWithBlocksForDidFinishBlock:^(NSInteger toalCount, NSInteger succeedCount, NSArray *credentialsForFailures) {
      [self showAlertViewWithText:@"Finished!"];
    } didSendOneBlock:^(DOUVenderAPIResponse *resp) {
      [self showAlertViewWithText:@"succeed to send one"];
    } didFailOneBlock:^(NSError *error, DOUOAuth2VenderType venderType) {
      [self showAlertViewWithText:[NSString stringWithFormat:@"error %@, vender type : %d", error, venderType]];
    }];
    
    [self.requestManager sendStatus:[NSString stringWithFormat:@"%@ Test$$$", [NSDate date]]
                    withCredentials:enabledArr
                       extraOptions:renrenOptions];
