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

#### 使用方式

###### 第一步 作为submodule，加入项目的git创库中

	$  git submodule add https://github.com/douban/DOUSNSSharing.git ${path}
	$  cd ${path}
	$  git checkout ${version}
	$  git submodule update --init --recursive
  	
###### 第二步 加入项目编译依赖和静态链接库
	* 在Build Phases -> Target Dependencies 中加入target：DOUSNSSharing
	* 在Build Phases -> Link Binary With Libraries 中加入链接库：libDOUSNSSharing.a

###### 第三步 使用认证的功能
详细可以查看Demo中的OAuthSampleBaseViewController

	  self.authorizationManager = [[DOUOAuth2AuthorizationManager alloc] initWithClientid:[self venderAPIKey]
                                                                               secret:[self venderAPISecrect]
                                                                           venderType:[self venderType]];

	  [self.authorizationManager setBlocksForDidSucceedBlock:^(DOUOAuth2Credential *credential) {
		
	  } didFailBlock:^(NSError *error) {

	  } didCancelBlock:^(DOUOAuth2Credential *credential) {

	  }];
	  UIView *oauthView = [self.authorizationManager requestWithRedirectUri:[self oauthRedirectURL]
                                                                  scope:nil];
	  [self.view addSubview:oauthView];

###### 第四步 使用分享功能
详细可以查看Demo中的AuthorizationSamplesViewController

	self.requestManager = [[DOUVenderAPIRequestManager alloc] 	initWithBlocksForDidFinishBlock:^(NSInteger toalCount, NSInteger succeedCount, NSArray *credentialsForFailures) {
      [self showAlertViewWithText:@"Finished!"];
    } didSendOneBlock:^(DOUVenderAPIResponse *resp) {
      [self showAlertViewWithText:@"succeed to send one"];
    } didFailOneBlock:^(NSError *error, DOUOAuth2VenderType venderType) {
      [self showAlertViewWithText:[NSString stringWithFormat:@"error %@, vender type : %d", error, venderType]];
    }];
    
    [self.requestManager sendStatus:[NSString stringWithFormat:@"%@ Test$$$", [NSDate date]]
                    withCredentials:enabledArr
                       extraOptions:renrenOptions];



#### ChangeLog ####
###### 2.3.4
* Fix for iPad display

###### V2.3.3
* Support Douban

###### V2.3.2
* Fix warnings in Xcode 5
* Update demo : remove api keys

###### V2.3.1 Bug Fix
* Increase succ count
* Update renren error code

###### V2.3更新日志
* Bug fix : 人人授权加上了publish_feed

###### V2.2更新日志
* 在OAuth认证后，加上User Info的获取
* Bug fix : 处理了一些json解析的错误

###### V2.1更新日志
* 加了错误码：区分网络错误，OAuth错误，http服务错误等
* 更新了demo

###### V2.0更新日志
* 统一了一些model：credential
* 统一了接口，详细见： DOUOAuth2AuthorizationManager.h DOUVenderAPIRequestManager.h
* 更新了demo

