//
//  DOUAuthorizationSinaWeiboHandler.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUAuthorizationSinaWeiboServiceHandler.h"
#import "DOUSinaWeiboOAuth2APIRequest.h"
#import "NSError+OAuth2.h"
#import "NSDate+ExpiresIn.h"

@interface DOUAuthorizationSinaWeiboServiceHandler ()
@property (nonatomic, strong) DOUOAuth2Credential *credentail;
@end

@implementation DOUAuthorizationSinaWeiboServiceHandler

- (id)initWithCredentail:(DOUOAuth2Credential *)credentail
{
  self = [super init];
  if (self) {
    self.credentail = credentail;
  }
  return self;
}

- (NSString *)venderOAuthWebURLBasePath
{
  return @"https://api.weibo.com/oauth2/authorize";
}

- (DOUAuthorizationResult)resultFromAuthorizationRequest:(NSURLRequest *)request
                                             redirectURL:(NSString *)redirectURLStr
                                       aurhorizationCode:(NSString **)code
                                        credentialToFill:(DOUOAuth2Credential *)credential
                                                errorStr:(NSString **)errStr
{
  NSURL *url = request.URL;
  NSString *s = [url absoluteString];
  NSString *host = [url host];
  NSURL *redirectURL = [NSURL URLWithString:redirectURLStr];
  
  if ([s isEqualToString:@"https://api.weibo.com/oauth2/authorize"]) {
    if ([[request HTTPMethod] isEqualToString:@"POST"]) {
      NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
      DOUSNSSharingDebugLog(@"body:%@", body);
      NSDictionary *parameters = [body decodedUrlencodedParameters];
      NSString *action = [parameters objectForKey:@"action"];
      if ([action isEqualToString:@"refused"]) {
        return kDOUAuthorizationResultCancelled;
      }
    }
  } else if ([host isEqualToString:[redirectURL host]]) {
    NSDictionary *p = [s queryParameters];
    NSError *error = [NSError errorByCheckingOAuthv2RedirectURIParameters:p];
    if (nil == error) {
      NSString *authorizationCode = [p objectForKey:kOAuthv2AuthorizationCode];
      if (authorizationCode) {
        *code = authorizationCode;
        return kDOUAuthorizationResultDidGetCode;
      } else {
        *errStr = @"No aurhorization code in result";
        return kDOUAuthorizationResultDidFail;
      }
    } else {
      *errStr = [error description];
      return kDOUAuthorizationResultDidFail;
    }
    return NO;
  }
  return kDOUAuthorizationResultNone;
}

- (id<DOUVenderOAuth2APIRequest>)oauth2APIRequestWithCredential:(DOUOAuth2Credential *)credential
{
  return [[DOUSinaWeiboOAuth2APIRequest alloc] initWithCredentail:credential];
}

- (NSString *)scopeWithdDefault:(NSString *)additionalScope
{
  return additionalScope;
}

@end
