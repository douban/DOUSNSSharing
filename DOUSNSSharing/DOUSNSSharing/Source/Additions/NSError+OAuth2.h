//
//  NSError+OAuth2.h
//  SharingRequest
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kOAuthv2ErrorKey;                                  //error
extern NSString * const kOAuthv2ErrorInvalidRequest;                       //invalid_request
extern NSString * const kOAuthv2ErrorInvalidClient;                        //invalid_client
extern NSString * const kOAuthv2ErrorInvalidGrant;                         //invalid_grant
extern NSString * const kOAuthv2ErrorUnauthorizedClient;                   //unauthorized_client
extern NSString * const kOAuthv2ErrorAccessDenied;                         //access_denied
extern NSString * const kOAuthv2ErrorUnsupportedResponseType;              //unsupported_response_type
extern NSString * const kOAuthv2ErrorInvalidScope;                         //invalid_scope
extern NSString * const kOAuthv2ErrorServerError;                          //server_error
extern NSString * const kOAuthv2ErrorTemporarilyUnavailable;               //temporarily_unavailable

extern NSString * const kOAuthv2ErrorDescriptionKey;                       //error_description
extern NSString * const kOAuthv2ErrorURIKey;                               //error_uri

extern NSString * const kOAuthv2ErrorDomain;

typedef enum kOAuthv2ErrorTypeCode {
  kOAuthv2ErrorTypeCodeInvalidRequest,
  kOAuthv2ErrorTypeCodeInvalidClient,
  kOAuthv2ErrorTypeCodeInvalidGrant,
  kOAuthv2ErrorTypeCodeUnauthorizedClient,
  kOAuthv2ErrorTypeCodeAccessDenied,
  kOAuthv2ErrorTypeCodeUnsupportedResponseType,
  kOAuthv2ErrorTypeCodeInvalidScope,
  kOAuthv2ErrorTypeCodeServerError,
  kOAuthv2ErrorTypeCodeTemporarilyUnavailable,
  kOAuthv2ErrorTypeCodeMax
}kOAuthv2ErrorTypeCode;

@interface NSError (OAuth2)

+ (NSError *)errorByCheckingOAuthv2RedirectURI:(NSString *)redirect_uri;
+ (NSError *)errorByCheckingOAuthv2RedirectURIParameters:(NSDictionary *)parameters;

@end
