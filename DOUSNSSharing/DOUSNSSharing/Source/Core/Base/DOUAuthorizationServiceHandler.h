//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUOAuth2AuthorizationService.h"
#import "DOUVenderOAuth2APIRequestBase.h"

typedef enum {
  kDOUAuthorizationResultNone = 0,
  kDOUAuthorizationResultCancelled,
  kDOUAuthorizationResultDidGetCode,
  kDOUAuthorizationResultDidGetAccessToken,
  kDOUAuthorizationResultDidFail
} DOUAuthorizationResult;

@protocol DOUAuthorizationServiceHandler <NSObject>
- (id)initWithCredentail:(DOUOAuth2Credential *)credentail;
- (NSString *)venderOAuthWebURLBasePath;
- (DOUAuthorizationResult)resultFromAuthorizationRequest:(NSURLRequest *)request
                                             redirectURL:(NSString *)redirectURLStr
                                       aurhorizationCode:(NSString **)code
                                        credentialToFill:(DOUOAuth2Credential *)credential
                                                errorStr:(NSString **)errStr;
- (id<DOUVenderOAuth2APIRequest>)oauth2APIRequestWithCredential:(DOUOAuth2Credential *)credential;
- (NSString *)scopeWithdDefault:(NSString *)additionalScope;
@end
