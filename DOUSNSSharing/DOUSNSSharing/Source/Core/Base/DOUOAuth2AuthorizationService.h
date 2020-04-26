//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUOAuth2Credential.h"

@class DOUOAuth2AuthorizationService;
@protocol DOUAuthorizationServiceHandler;
@class WKWebView;

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

- (void)requestWithRedirectUri:(NSString *)uri
                  responseType:(DOUOAuthAuthorizationResponseType)type
                         scope:(NSString *)scope
                       display:(DOUOAuthAuthorizationDisplayType)display
                     inWebView:(WKWebView *)webView;
- (void)requestWithRedirectUri:(NSString *)uri
                         scope:(NSString *)scope
                     inWebView:(WKWebView *)webView;
- (void)cancelAndClearBlocks;

@end


@interface DOUOAuth2AuthorizationService : NSObject <DOUOAuth2AuthorizationService>

@property (nonatomic, weak) id<DOUOAuth2AuthorizationDelegate> delegate;
@property (nonatomic, readonly) DOUOAuth2Credential *credential;

- (id)initWithCredential:(DOUOAuth2Credential *)credential
           venderService:(id<DOUAuthorizationServiceHandler>)serviceHandler;

@end
