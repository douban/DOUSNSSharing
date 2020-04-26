//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "DOUOAuth2AuthorizationService.h"
#import "NSString+OAuth2.h"
#import "DOUVenderOAuth2APIRequestProtocol.h"
#import "DOUAuthorizationServiceHandler.h"
#import "DOUVenderAPIResponse.h"

@interface DOUOAuth2AuthorizationService () <WKNavigationDelegate, UIScrollViewDelegate>
@property (nonatomic, copy) DOUOAuth2Credential *credential;
@property (nonatomic, copy) NSString *redirectURLStr;
@property (nonatomic, assign) DOUOAuthAuthorizationResponseType responseType;
@property (nonatomic, strong) id<DOUAuthorizationServiceHandler> serviceHandler;
@property (nonatomic, strong) id<DOUVenderOAuth2APIRequest> exchangeTokenRequest;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivity;

@end

@implementation DOUOAuth2AuthorizationService
{
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

- (void)requestWithRedirectUri:(NSString *)redirectURL
                  responseType:(DOUOAuthAuthorizationResponseType)type
                         scope:(NSString *)scope
                       display:(DOUOAuthAuthorizationDisplayType)display
                     inWebView:(WKWebView *)webView
{
  NSAssert(webView.superview, @"Add webView as subview for loading requests");

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
  
  self.loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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

  [webView loadRequest:request];

  self.webView = webView;
}

- (void)requestWithRedirectUri:(NSString *)uri
                         scope:(NSString *)scope
                     inWebView:(WKWebView *)webView
{
  [self requestWithRedirectUri:uri
                  responseType:kDOUOAuthAuthorizationResponseTypeCode
                         scope:scope
                       display:kDOUOAuthAuthorizationDisplayMobile
                     inWebView:webView];
}

- (void)cancelAndClearBlocks
{
  [self.exchangeTokenRequest cancelAndClearBlocks];
  self.exchangeTokenRequest = nil;
  [self.delegate authorizationDidCancel:self];
  self.webView.navigationDelegate = nil;
  self.webView.scrollView.delegate = nil;
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
  decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
  decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
  NSString *authorizedCode = nil;
  NSString *errStr = nil;
  DOUAuthorizationResult result = [self.serviceHandler resultFromAuthorizationRequest:navigationAction.request
                                                                          redirectURL:self.redirectURLStr
                                                                    aurhorizationCode:&authorizedCode
                                                                     credentialToFill:self.credential
                                                                             errorStr:&errStr];
  switch (result) {
    case kDOUAuthorizationResultNone: {
      decisionHandler(WKNavigationActionPolicyCancel);
      break;
    }

    case kDOUAuthorizationResultCancelled: {
      [self.delegate authorizationDidCancel:self];
      decisionHandler(WKNavigationActionPolicyCancel);
      break;
    }

    case kDOUAuthorizationResultDidGetCode: {
      id<DOUVenderOAuth2APIRequest> req = [self.serviceHandler oauth2APIRequestWithCredential:self.credential];
      [req getAccessTokenWithCode:authorizedCode redirectUri:self.redirectURLStr];
      [req setDidSucceedBlock:^(id < DOUVenderOAuth2APIRequest > request) {
        DOUVenderAPIResponse *resp = [request apiResponse];
        self.credential = resp.venderOAuth2Credential;
        if (self.credential.accessToken) {
          [self getUserInfoAfterAuthorization];
        } else {
          NSError *err = [NSError errorWithDomain:@"DOUOAuth2AuthorizationService"
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
      decisionHandler(WKNavigationActionPolicyCancel);
      break;
    }

    case kDOUAuthorizationResultDidGetAccessToken: {
      if (self.credential.accessToken) {
        [self getUserInfoAfterAuthorization];
      } else {
        NSError *err = [NSError errorWithDomain:@"DOUOAuth2AuthorizationService"
                                           code:1
                                       userInfo:@{ @"error": @"access token is nil" }];
        [self.delegate authorization:self didFailWithError:err];
      }
      decisionHandler(WKNavigationActionPolicyCancel);
      break;
    }

    case kDOUAuthorizationResultDidFail: {
      DOUSNSSharingWarnLog(@"Authorization failed: request(%@), error(%@)", navigationAction.request, errStr);
      NSError *err = [NSError errorWithDomain:@"DOUOAuth2AuthorizationService" code:1 userInfo:@{ @"error": errStr }];
      [self.delegate authorization:self didFailWithError:err];
      decisionHandler(WKNavigationActionPolicyCancel);
      break;
    }
  }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
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

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
  [self.loadingActivity stopAnimating];
  [self.loadingActivity removeFromSuperview];
  self.loadingActivity = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
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
