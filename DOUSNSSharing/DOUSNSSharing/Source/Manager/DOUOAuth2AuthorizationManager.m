//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUOAuth2AuthorizationManager.h"
#import "DOUVenderOAuth2ImplFactory.h"

@interface DOUOAuth2AuthorizationManager ()
@property (nonatomic, strong, readwrite) DOUOAuth2AuthorizationService *activeAuthorizationService;
@property (nonatomic, copy) DOUOAuth2AuthorizeDidSucceedBlock didSucceedBlock;
@property (nonatomic, copy) DOUOAuth2AuthorizeDidFailBlock didFailBlock;
@property (nonatomic, copy) DOUOAuth2AuthorizeDidCancelBlock didCancelBlock;
@end

@implementation DOUOAuth2AuthorizationManager

- (id)initWithVenderAPIKey:(NSString *)apiKey
                    secret:(NSString *)secret
                venderType:(DOUOAuth2VenderType)type
{
  NSParameterAssert(apiKey != nil && apiKey.length > 0);
  NSParameterAssert(secret != nil && secret.length > 0);
  
  self = [super init];
  if (self) {
    DOUOAuth2Credential *credential = [[DOUOAuth2Credential alloc] initWithAPIKey:apiKey
                                                                             secret:secret
                                                                         venderType:type];
    id serviceHandler = [DOUVenderOAuth2ImplFactory authorizationServiceByVenderCredential:credential];
    self.activeAuthorizationService = [[DOUOAuth2AuthorizationService alloc] initWithCredential:credential
                                                                                  venderService:serviceHandler];
    self.activeAuthorizationService.delegate = self;
  }
  return self;
}

- (void)dealloc
{
  [self cancelAndClearBlocks];
}

- (void)setBlocksForDidSucceedBlock:(DOUOAuth2AuthorizeDidSucceedBlock)didSucceedBlock
                       didFailBlock:(DOUOAuth2AuthorizeDidFailBlock)didFailBlock
                     didCancelBlock:(DOUOAuth2AuthorizeDidCancelBlock)didCancelBlock
{
  self.didSucceedBlock = didSucceedBlock;
  self.didFailBlock = didFailBlock;
  self.didCancelBlock = didCancelBlock;
}

- (UIView *)requestWithRedirectUri:(NSString *)uri
                      responseType:(DOUOAuthAuthorizationResponseType)type
                             scope:(NSString *)scope
                           display:(DOUOAuthAuthorizationDisplayType)display
{
  return [self.activeAuthorizationService
          requestWithRedirectUri:uri
          responseType:type
          scope:scope
          display:display];
}

- (UIView *)requestWithRedirectUri:(NSString *)uri scope:(NSString *)scope
{
  return [self.activeAuthorizationService requestWithRedirectUri:uri scope:scope];
}

- (void)cancelAndClearBlocks
{
  [self clearBlocks];
  self.activeAuthorizationService.delegate = nil;
  [self.activeAuthorizationService cancelAndClearBlocks];
  self.activeAuthorizationService = nil;
}

- (void)clearBlocks
{
  self.didFailBlock = nil;
  self.didSucceedBlock = nil;
  self.didCancelBlock = nil;
}

#pragma mark - DOUOAuth2AuthorizationDelegate
- (void)authorizationDidFinish:(DOUOAuth2AuthorizationService *)authorization
{
  if (self.didSucceedBlock) {
    DOUSNSSharingInfoLog(@"authorizationDidFinish:");
    self.didSucceedBlock(authorization.credential);
    [self clearBlocks];
  }
}

- (void)authorization:(DOUOAuth2AuthorizationService *)authorization didFailWithError:(NSError *)error
{
  if (self.didFailBlock) {
    DOUSNSSharingInfoLog(@"authorization:didFailWithError:");
    self.didFailBlock(error);
    [self clearBlocks];
  }
}

- (void)authorizationDidCancel:(DOUOAuth2AuthorizationService *)authorization
{
  if (self.didCancelBlock) {
    DOUSNSSharingInfoLog(@"authorizationDidCancel:");
    self.didCancelBlock(authorization.credential);
    [self clearBlocks];
  }
}

@end