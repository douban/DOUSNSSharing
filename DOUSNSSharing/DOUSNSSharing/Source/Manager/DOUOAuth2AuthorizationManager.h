//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUSharingLibConstants.h"
#import "DOUOAuth2AuthorizationService.h"

@class WKWebView;

typedef void (^DOUOAuth2AuthorizeDidSucceedBlock)(DOUOAuth2Credential *credential);
typedef void (^DOUOAuth2AuthorizeDidFailBlock)(NSError *error);
typedef void (^DOUOAuth2AuthorizeDidCancelBlock)(DOUOAuth2Credential *credential);

@interface DOUOAuth2AuthorizationManager : NSObject <DOUOAuth2AuthorizationDelegate>

- (instancetype)initWithVenderAPIKey:(NSString *)apiKey
                              secret:(NSString *)secret
                          venderType:(DOUOAuth2VenderType)type;

- (void)setBlocksForDidSucceedBlock:(DOUOAuth2AuthorizeDidSucceedBlock)didSucceedBlock
                       didFailBlock:(DOUOAuth2AuthorizeDidFailBlock)didFailBlock
                     didCancelBlock:(DOUOAuth2AuthorizeDidCancelBlock)didCancelBlock;

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
