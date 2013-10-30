//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, DOUOAuth2VenderType) {
  kDOUOAuth2VenderAll = 999,
  kDOUOAuth2VenderDouban = 1,
  kDOUOAuth2VenderSinaWeibo = 2,
  kDOUOAuth2VenderTencentWeibo = 3,
  kDOUOAuth2VenderRenren = 4
};

extern NSString * const kDOUShareLibErrorDomain;
extern NSString * const kDOUShareLibErrorInfoKeyReason;
extern NSString * const kDOUShareLibErrorInfoKeyAPIErrorCode;

typedef enum {
  kDOUShareLibRequestErrorNone = 0,
  kDOUShareLibRequestErrorOAuthInvalid,
  kDOUShareLibRequestErrorException,
  kDOUShareLibRequestErrorNetwork,
  kDOUShareLibRequestErrorVenderServiceError,
  kDOUShareLibRequestErrorInvalidParam
} DOUShareLibRequestError;

extern NSString * const kOAuthv2ResponseType;                              //response_type
extern NSString * const kOAuthv2AuthorizationCode;                         //code
extern NSString * const kOAuthv2ImplictGrant;                              //token

extern NSString * const kOAuthv2ClientId;                                  //client_id
extern NSString * const kOAuthv2ClientSecret;                              //client_secret
extern NSString * const kOAuthv2RedirectURI;                               //redirect_uri
extern NSString * const kOAuthv2Scope;                                     //scope
extern NSString * const kOAuthv2State;                                     //state

extern NSString * const kOAuthv2GrantType;                                 //grant_type
extern NSString * const kOAuthv2GrantTypeAuthorizationCode;                //authorization_code
extern NSString * const kOAuthv2GrantTypeResourceOwnerPasswordCredentials; //password
extern NSString * const kOAuthv2ResourceOwnerUsername;                     //username
extern NSString * const kOAuthv2ResourceOwnerPassword;                     //password
extern NSString * const kOAuthv2GrantTypeClientCredentials;                //client_credentials
extern NSString * const kOAuthv2GrantTypeRefreshToken;                     //refresh_token

extern NSString * const kOAuthv2AccessToken;                               //access_token
extern NSString * const kOAuthv2TokenType;                                 //token_type
extern NSString * const kOAuthv2ExpiresIn;                                 //expires_in
extern NSString * const kOAuthv2RefreshToken;                              //refresh_token

#define DOU_LIB_ERROR_INVALID_PARAM @"Invalid parameter"
