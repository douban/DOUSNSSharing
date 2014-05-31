//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOUOAuth2AuthorizationService.h"
#import "NSString+OAuth2.h"

@interface DOUOAuth2AuthorizationService ()
@property (nonatomic, readwrite, copy) DOUOAuth2Credential *credential;
@property (nonatomic, readwrite, strong) NSString *redirectURLStr;
@property (nonatomic, assign) DOUOAuthAuthorizationResponseType responseType;
@property (nonatomic, strong) id<DOUAuthorizationServiceHandler> serviceHandler;
@property (nonatomic, strong) id<DOUVenderOAuth2APIRequest> exchangeTokenRequest;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivity;

@end

@implementation DOUOAuth2AuthorizationService {
  NSString *_redirectUri;
  NSURLConnection *_connection;
}

- (void)dealloc
{
  [self cancelAndClearBlocks];
}

- (id)initWithCredential:(DOUOAuth2Credential *)credential
           venderService:(id<DOUAuthorizationServiceHandler>)serviceHandler
{
  self = [super init];
  if (self) {
    self.credential = credential;
    self.serviceHandler = serviceHandler;
  }
  return self;
}

- (UIView *)requestWithRedirectUri:(NSString *)redirectURL
                      responseType:(DOUOAuthAuthorizationResponseType)type
                             scope:(NSString *)scope
                           display:(DOUOAuthAuthorizationDisplayType)display
{
  self.redirectURLStr = redirectURL;
  self.responseType = type;
  NSString *urlString = [self.serviceHandler venderOAuthWebURLBasePath];
  scope = [self.serviceHandler scopeWithdDefault:scope];
  NSMutableDictionary *params = [self requestParamsForAuthorizationCodeByAddingAPIKey:self.credential.apiKey
                                                                            redirectURI:self.redirectURLStr
                                                                                  scope:scope
                                                                                  state:nil];
  if (display == kDOUOAuthAuthorizationDisplayMobile) {
    [params setObject:@"mobile" forKey:@"display"];
  }
  urlString = [urlString URLStringByAddingParameters:params];
  NSMutableURLRequest *request = nil;
  if (params) {
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPShouldHandleCookies:NO];
  }
  
  UIWebView *authorizationWebView = [[UIWebView alloc] init];
  authorizationWebView.delegate = self;
  [authorizationWebView loadRequest:request];
  self.webView = authorizationWebView;
  
  
  self.loadingActivity = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.loadingActivity.hidesWhenStopped = YES;
  [self.webView addSubview:self.loadingActivity];
  [self.loadingActivity startAnimating];
  
  CGRect webviewFrame = self.webView.frame;
  CGRect loadingActivityFrame = self.loadingActivity.frame;
  CGFloat origX = ceilf(CGRectGetMidX(webviewFrame) - loadingActivityFrame.size.width * .5f);
  CGFloat origY = ceilf(CGRectGetMidY(webviewFrame) - loadingActivityFrame.size.height * .5f);
  loadingActivityFrame.origin = CGPointMake(origX, origY);
  self.loadingActivity.frame = loadingActivityFrame;
  self.loadingActivity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
  | UIViewAutoresizingFlexibleLeftMargin
  | UIViewAutoresizingFlexibleRightMargin
  | UIViewAutoresizingFlexibleTopMargin;
  
  return authorizationWebView;
}

- (UIView *)requestWithRedirectUri:(NSString *)uri
                             scope:(NSString *)scope
{
  return [self requestWithRedirectUri:uri
                         responseType:kDOUOAuthAuthorizationResponseTypeCode
                                scope:scope
                              display:kDOUOAuthAuthorizationDisplayMobile];
}

- (void)cancelAndClearBlocks
{
  [self.exchangeTokenRequest cancelAndClearBlocks];
  self.exchangeTokenRequest = nil;
  [self.delegate authorizationDidCancel:self];
  self.webView.delegate = nil;
  [self.webView stopLoading];
  self.webView = nil;
  self.loadingActivity = nil;
  self.delegate = nil;
}

- (void)getUserInfoAfterAuthorization
{
  id<DOUVenderOAuth2APIRequest> req = [self.serviceHandler oauth2APIRequestWithCredential:self.credential];
  [req getUserInfo];
  [req setDidSucceedBlock:^(id < DOUVenderOAuth2APIRequest > request) {
    DOUVenderAPIResponse *resp = [request apiResponse];
    NSString *userID = self.credential.userid;
    NSString *userName = resp.venderUserInfo.screeNname ? resp.venderUserInfo.screeNname : resp.venderUserInfo.name;
    if (self.credential.userid == nil) {
      userID = resp.venderUserInfo.userID;
    }
    [self.credential setUserName:userName userID:userID];
    [self.delegate authorizationDidFinish:self];
  } didFailBlock:^(id<DOUVenderOAuth2APIRequest> request, NSError *error) {
    DOUSNSSharingWarnLog(@"Error when get user info after authorization, error : %@", error);
    [self.delegate authorizationDidFinish:self];
  } didCancelBlock:^(id<DOUVenderOAuth2APIRequest> request) {
    [self.delegate authorizationDidCancel:self];
  }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)             webView:(UIWebView *)webView
  shouldStartLoadWithRequest:(NSURLRequest *)request
              navigationType:(UIWebViewNavigationType)navigationType
{
  NSString *authorizedCode = nil;
  NSString *errStr = nil;
  DOUAuthorizationResult result = [self.serviceHandler resultFromAuthorizationRequest:request
                                                                          redirectURL:self.redirectURLStr
                                                                    aurhorizationCode:&authorizedCode
                                                                     credentialToFill:self.credential
                                                                             errorStr:&errStr];
  if (result == kDOUAuthorizationResultNone) {
    return YES;
  } else if (result == kDOUAuthorizationResultCancelled) {
    [self.delegate authorizationDidCancel:self];
    return NO;
  } else if (result == kDOUAuthorizationResultDidGetCode) {
    id<DOUVenderOAuth2APIRequest> req = [self.serviceHandler oauth2APIRequestWithCredential:self.credential];
    [req getAccessTokenWithCode:authorizedCode redirectUri:self.redirectURLStr];
    [req setDidSucceedBlock:^(id < DOUVenderOAuth2APIRequest > request) {
      DOUVenderAPIResponse *resp = [request apiResponse];
      self.credential = resp.venderOAuth2Credential;
      if (self.credential.accessToken) {
        [self getUserInfoAfterAuthorization];
      } else {
        NSError *err = [NSError     errorWithDomain:@"DOUOAuth2AuthorizationService"
                                               code:1
                                           userInfo:@{ @"error": @"access token is nil" }];
        [self.delegate authorization:self didFailWithError:err];
      }
    } didFailBlock:^(id<DOUVenderOAuth2APIRequest> request, NSError *error) {
      [self.delegate authorization:self didFailWithError:error];
    } didCancelBlock:^(id<DOUVenderOAuth2APIRequest> request) {
      [self.delegate authorizationDidCancel:self];
    }];
    self.exchangeTokenRequest = req;
    return NO;
  } else if (result == kDOUAuthorizationResultDidGetAccessToken) {
    if (self.credential.accessToken) {
      [self getUserInfoAfterAuthorization];
    } else {
      NSError *err = [NSError errorWithDomain:@"DOUOAuth2AuthorizationService"
                                         code:1
                                     userInfo:@{ @"error": @"access token is nil" }];
      [self.delegate authorization:self didFailWithError:err];
    }
    return NO;
  } else if (result == kDOUAuthorizationResultDidFail) {
    DOUSNSSharingWarnLog(@"Authorization failed: request(%@), error(%@)", request, errStr);
    NSError *err = [NSError errorWithDomain:@"DOUOAuth2AuthorizationService" code:1 userInfo:@{ @"error": errStr }];
    [self.delegate authorization:self didFailWithError:err];
    return NO;
  } else {
    DOUSNSSharingWarnLog(@"Should not be here with request: %@", request);
    return NO;
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    UIScrollView *scrollView = [webView scrollView];
    CGSize contentSize = [scrollView contentSize];

    NSAssert([webView superview] != nil, @"webView has no superview");
    CGSize containerSize = [[webView superview] bounds].size;

    CGFloat offsetX = roundf((contentSize.width - containerSize.width) / 2.0f);
    if (offsetX > 0.0f) {
      [scrollView setContentOffset:CGPointMake(offsetX, 0.0f)];
    }
  }

  [self.loadingActivity stopAnimating];
  [self.loadingActivity removeFromSuperview];
  self.loadingActivity = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [self.loadingActivity stopAnimating];
  [self.loadingActivity removeFromSuperview];
  self.loadingActivity = nil;
}

#pragma mark - util

- (NSMutableDictionary *)requestParamsForAuthorizationCodeByAddingAPIKey:(NSString *)client_id
                                                               redirectURI:(NSString *)redirect_uri
                                                                     scope:(NSString *)scope
                                                                     state:(NSString *)state
{
  if (nil == client_id) {
    return nil;
  }
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:5];
  [parameters setObject:kOAuthv2AuthorizationCode forKey:kOAuthv2ResponseType];
  [parameters setObject:client_id forKey:kOAuthv2ClientId];
  if (redirect_uri) {
    [parameters setObject:redirect_uri forKey:kOAuthv2RedirectURI];
  }
  if (scope) {
    [parameters setObject:scope forKey:kOAuthv2Scope];
  }
  if (state) {
    [parameters setObject:state forKey:kOAuthv2State];
  }
  return parameters;
}

@end
