//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUSharingLibConstants.h"
#import "DOUVenderOAuth2APIRequestProtocol.h"
#import "DOUOAuth2Credential.h"
#import "DOUOAuth2AuthorizationService.h"
#import "DOUAuthorizationServiceHandler.h"

@interface DOUVenderOAuth2ImplFactory : NSObject

+ (id<DOUVenderOAuth2APIRequest>)createReqeustByVenderCredential:(DOUOAuth2Credential *)venderCredential;
+ (id<DOUAuthorizationServiceHandler>)authorizationServiceByVenderCredential:(DOUOAuth2Credential *)credential;
@end
