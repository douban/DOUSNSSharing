//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DOUOAuth2Credential.h"
#import "DOUAuthorizationServiceHandler.h"

@class DOUOAuth2AuthorizationService;

typedef enum {
  kDOUOAuthAuthorizationResponseTypeCode,
} DOUOAuthAuthorizationResponseType;

typedef enum  {
  kDOUOAuthAuthorizationDisplayDefault,
  kDOUOAuthAuthorizationDisplayMobile,
} DOUOAuthAuthorizationDisplayType;

@protocol DOUOAuth2AuthorizationDelegate <NSObject>
- (void)authorizationDidFinish:(DOUOAuth2AuthorizationService *)authorization;
- (void)authorization:(DOUOAuth2AuthorizationService *)authorization didFailWithError:(NSError *)error;
- (void)authorizationDidCancel:(DOUOAuth2AuthorizationService *)authorization;
@end


@protocol DOUOAuth2AuthorizationService <NSObject>

- (UIView *)requestWithRedirectUri:(NSString *)uri
                         responseType:(DOUOAuthAuthorizationResponseType)type
                                scope:(NSString *)scope
                              display:(DOUOAuthAuthorizationDisplayType)display;
- (UIView *)requestWithRedirectUri:(NSString *)uri
                                scope:(NSString *)scope;

- (void)cancelAndClearBlocks;

@end


@interface DOUOAuth2AuthorizationService : NSObject <UIWebViewDelegate, DOUOAuth2AuthorizationService>

@property (nonatomic, unsafe_unretained) id<DOUOAuth2AuthorizationDelegate> delegate;
@property (nonatomic, readonly, copy) DOUOAuth2Credential *credential;

- (id)initWithCredential:(DOUOAuth2Credential *)credential
           venderService:(id<DOUAuthorizationServiceHandler>)serviceHandler;

@end
