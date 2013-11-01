//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderOAuth2ImplFactory.h"
#import "DOUAuthorizationDoubanServiceHandler.h"
#import "DOUAuthorizationSinaWeiboServiceHandler.h"
#import "DOUAuthorizationTencentWeiboServiceHandler.h"
#import "DOUAuthorizationRenrenServiceHandler.h"
#import "DOUDoubanOAuth2APIRequest.h"
#import "DOUSinaWeiboOAuth2APIRequest.h"
#import "DOUTencentWeiboOAuth2APIRequest.h"
#import "DOURenrenOAuth2APIRequest.h"

@implementation DOUVenderOAuth2ImplFactory

+ (id<DOUVenderOAuth2APIRequest>)createReqeustByVenderCredential:(DOUOAuth2Credential *)credential
{
  DOUOAuth2VenderType venderType = credential.venderType.integerValue;
  id<DOUVenderOAuth2APIRequest> apiRequest = nil;
  switch (venderType) {
    case kDOUOAuth2VenderDouban:
      apiRequest = [[DOUDoubanOAuth2APIRequest alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderSinaWeibo:
      apiRequest = [[DOUSinaWeiboOAuth2APIRequest alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderTencentWeibo:
      apiRequest = [[DOUTencentWeiboOAuth2APIRequest alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderRenren:
      apiRequest = [[DOURenrenOAuth2APIRequest alloc] initWithCredentail:credential];
      break;
    default:
      break;
  }
  return apiRequest;
}

+ (id<DOUAuthorizationServiceHandler>)authorizationServiceByVenderCredential:(DOUOAuth2Credential *)credential
{
  if (credential.venderType == nil) {
    DOUSNSSharingWarnLog(@"credentail should not be nil");
    return nil;
  }
  DOUOAuth2VenderType venderType = credential.venderType.integerValue;
  id<DOUAuthorizationServiceHandler> handler = nil;
  switch (venderType) {
    case kDOUOAuth2VenderDouban:
      handler = [[DOUAuthorizationDoubanServiceHandler alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderSinaWeibo:
      handler = [[DOUAuthorizationSinaWeiboServiceHandler alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderTencentWeibo:
      handler = [[DOUAuthorizationTencentWeiboServiceHandler alloc] initWithCredentail:credential];
      break;
    case kDOUOAuth2VenderRenren:
      handler = [[DOUAuthorizationRenrenServiceHandler alloc] initWithCredentail:credential];
      break;
    default:
      break;
  }
  return handler;
}

@end
