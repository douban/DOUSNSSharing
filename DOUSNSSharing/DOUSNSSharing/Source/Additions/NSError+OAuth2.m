//
//  NSError+OAuth2.m
//  SharingRequest
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "NSError+OAuth2.h"
#import "NSString+OAuth2.h"
#import "NSDictionary+URL.h"
#import "DOUSharingLibConstants.h"

NSString *const kOAuthv2ErrorKey = @"error";
NSString *const kOAuthv2ErrorInvalidRequest = @"invalid_request";
NSString *const kOAuthv2ErrorInvalidClient = @"invalid_client";
NSString *const kOAuthv2ErrorInvalidGrant = @"invalid_grant";
NSString *const kOAuthv2ErrorUnauthorizedClient = @"unauthorized_client";
NSString *const kOAuthv2ErrorAccessDenied = @"access_denied";
NSString *const kOAuthv2ErrorUnsupportedResponseType = @"unsupported_response_type";
NSString *const kOAuthv2ErrorInvalidScope = @"invalid_scope";
NSString *const kOAuthv2ErrorServerError = @"server_error";
NSString *const kOAuthv2ErrorTemporarilyUnavailable = @"temporarily_unavailable";

NSString *const kOAuthv2ErrorDescriptionKey = @"error_description";
NSString *const kOAuthv2ErrorURIKey = @"error_uri";

NSString *const kOAuthv2ErrorDomain = @"kOAuthv2ErrorDomain";

static NSString *const kOAuthv2ErrorLocalizedTable = @"ErrorLocalizedString";

@implementation NSError (OAuth2)

+ (NSInteger)errorCodeFromErrorType:(NSString *)errorType
{
  if ([errorType isEqualToString:kOAuthv2ErrorInvalidRequest]) {
    return kOAuthv2ErrorTypeCodeInvalidRequest;
  } else if ([errorType isEqualToString:kOAuthv2ErrorInvalidClient]) {
    return kOAuthv2ErrorTypeCodeInvalidClient;
  } else if ([errorType isEqualToString:kOAuthv2ErrorInvalidGrant]) {
    return kOAuthv2ErrorTypeCodeInvalidGrant;
  } else if ([errorType isEqualToString:kOAuthv2ErrorUnauthorizedClient]) {
    return kOAuthv2ErrorTypeCodeUnauthorizedClient;
  } else if ([errorType isEqualToString:kOAuthv2ErrorAccessDenied]) {
    return kOAuthv2ErrorTypeCodeAccessDenied;
  } else if ([errorType isEqualToString:kOAuthv2ErrorUnsupportedResponseType]) {
    return kOAuthv2ErrorTypeCodeUnsupportedResponseType;
  } else if ([errorType isEqualToString:kOAuthv2ErrorInvalidScope]) {
    return kOAuthv2ErrorTypeCodeInvalidScope;
  } else if ([errorType isEqualToString:kOAuthv2ErrorServerError]) {
    return kOAuthv2ErrorTypeCodeServerError;
  } else if ([errorType isEqualToString:kOAuthv2ErrorTemporarilyUnavailable]) {
    return kOAuthv2ErrorTypeCodeTemporarilyUnavailable;
  } else {
    return 0;
  }
}

+ (NSError *)errorByCheckingOAuthv2RedirectURIParameters:(NSDictionary *)parameters
{
  NSString *errorType = [parameters objectForKey:kOAuthv2ErrorKey];
  if (errorType) {
    NSInteger errorCode = [self errorCodeFromErrorType:errorType];
    NSString *errorName = @"DoubanSNSSharingError";
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setObject:errorName forKey:NSLocalizedDescriptionKey];
    [userInfo addEntriesFromDictionary:parameters];
    return [[self class] errorWithDomain:kOAuthv2ErrorDomain
                                    code:errorCode
                                userInfo:userInfo];
  }
  return nil;
}

+ (NSError *)errorByCheckingOAuthv2RedirectURI:(NSString *)redirect_uri
{
  NSDictionary *parameters = [redirect_uri queryParameters];
  return [[self class] errorByCheckingOAuthv2RedirectURIParameters:parameters];
}

@end
