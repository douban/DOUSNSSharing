//
//  DOUDoubanOAuth2APIRequest.m
//
//  Copyright (c) 2013年 Douban Inc. All rights reserved.
//

#import "DOUDoubanOAuth2APIRequest.h"
#import "NSDate+ExpiresIn.h"
/**
 *  Doc: http://developers.douban.com/wiki/?title=oauth2
 */

@implementation DOUDoubanOAuth2APIRequest
{
  DOUVenderAPIRequestType _requestType;
  DOUVenderAPIResponse *_responseObject;
}

- (BOOL)postStatusesWithText:(NSString *)text
                       image:(UIImage *)image
{
  NSString *urlString = @"https://api.douban.com/v2/lifestream/statuses";
  
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  [parameters setObject:text forKey:@"text"];
  self.requestConnection = [[DOUHTTPConnection alloc] init];
  NSMutableURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
  
  if (image) {
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImage;
    req = [self.requestConnection
           multipartFormRequestWithPostMethodForPath:urlString
           parameters:parameters
           constructingBodyWithBlock:^(id < DOUMultipartFormData > formData) {
             [self fillMultipleFormData:formData withStatus:text image:image];
           }];
  }
  [self setAccessTokenToRequest:req token:self.credential.accessToken];
  [self sendHttpRequest:req];
  return YES;
}

- (BOOL)postStatusWithText:(NSString *)text
                     title:(NSString *)title
                       url:(NSString *)urlStr
{
  NSString *urlString = @"https://api.douban.com/v2/lifestream/statuses";
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  if (text != nil) {
    [parameters setObject:text forKey:@"text"];
  }
  if (title != nil) {
    [parameters setObject:title forKey:@"rec_title"];
  }
  if (urlStr != nil) {
    [parameters setObject:urlStr forKey:@"rec_url"];
  }
  [parameters setObject:text forKey:@"text"];
  
  self.requestConnection = [[DOUHTTPConnection alloc] init];
  NSMutableURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
  [self setAccessTokenToRequest:req token:self.credential.accessToken];
  [self sendHttpRequest:req];
  return YES;
}

- (BOOL)sendStatus:(NSString *)status extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  if (status) {
    _requestType = kDOUVenderAPIRequestTypeSendStatus;
    return [self postStatusesWithText:status image:nil];
  } else {
    return NO;
  }
}

- (BOOL)sendStatus:(NSString *)status
         withImage:(UIImage *)image
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  return [self postStatusesWithText:status image:image];
}

- (BOOL)sendStatus:(NSString *)status
      withImageUrl:(NSString *)url
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  if (status) {
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImageUrl;
    return [self postStatusWithText:status title:@"Image" url:url];
  } else {
    return NO;
  }
}

- (BOOL)getAccessTokenWithCode:(NSString *)code redirectUri:(NSString *)uri
{
  @try {
    _requestType = kDOUVenderAPIRequestTypeGetAccessToken;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:kOAuthv2GrantTypeAuthorizationCode forKey:kOAuthv2GrantType];
    [parameters setObject:code forKey:kOAuthv2AuthorizationCode];
    [parameters setObject:uri forKey:kOAuthv2RedirectURI];
    [parameters setObject:self.credential.apiKey forKey:kOAuthv2ClientId];
    [parameters setObject:self.credential.secret forKey:kOAuthv2ClientSecret];
    NSString *urlString = @"https://www.douban.com/service/auth2/token";
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
    [self sendHttpRequest:req];
    return YES;
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"ex : %@", exception);
    return NO;
  }
}

- (BOOL)getUserInfo
{
  @try {
    if (self.credential.accessToken) {
      _requestType = kDOUVenderAPIRequestTypeGetUserInfo;
      NSString *urlString = @"https://api.douban.com/v2/user/~me";
      self.requestConnection = [[DOUHTTPConnection alloc] init];
      NSMutableURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:nil];
      [self setAccessTokenToRequest:req token:self.credential.accessToken];
      [self sendHttpRequest:req];
      return YES;
    } else {
      [self failWithSNSShareLibError:kDOUShareLibRequestErrorOAuthInvalid reason:nil];
      return NO;
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"ex : %@", exception);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorException reason:nil];
    return NO;
  }
}

#pragma mark -
- (DOUVenderAPIResponse *)apiResponse
{
  if (nil == _responseObject) {
    NSString *responseJSONStr = self.requestConnection.responseString;
    switch (_requestType) {
      case kDOUVenderAPIRequestTypeSendStatus:
      case kDOUVenderAPIRequestTypeSendStatusWithImage:
      case kDOUVenderAPIRequestTypeSendStatusWithImageUrl: {
        DOUVenderPost *post = [[DOUVenderPost alloc] init];
        _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
        _responseObject.venderPostObject = post;
      }
        break;
      case kDOUVenderAPIRequestTypeGetAccessToken: {
        [self fillCredentailWithResponseText:responseJSONStr];
        _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
        _responseObject.venderOAuth2Credential = self.credential;
        break;
      }
      case kDOUVenderAPIRequestTypeGetUserInfo: {
        DOUVenderUserInfo *userInfo = [[DOUVenderUserInfo alloc] init];
        NSArray *users = [DOUSNSSharingUtil objectFromJSONString:responseJSONStr];
        if (users && [users isKindOfClass:[NSArray class]] && users.count > 0) {
          _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
          _responseObject.venderUserInfo = userInfo;
        }
      }
        break;
      default:
        break;
    }
  }
  return _responseObject;
}

#pragma mark - util method
- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *)errorCode
{
  NSDictionary *response = [DOUSNSSharingUtil objectFromJSONString:responseStr];
  if (IS_INSTANCE_OF(response, NSDictionary)) {
    id errorCodeObj = [response objectForKey:@"code"];
    if (errorCodeObj) {
      NSInteger doubanErrorCode = [errorCodeObj integerValue];
      if (doubanErrorCode == 102
          || doubanErrorCode == 103
          || doubanErrorCode == 106
          || doubanErrorCode == 119
          || doubanErrorCode == 123) {
        *errorCode = kDOUShareLibRequestErrorOAuthInvalid;
      }
      DOUSNSSharingErrorLog(@"error:%@", response);
      NSString *description = [response objectForKey:@"msg"];
      if (description == nil) {
        description = [response objectForKey:@"error_description"];
      }
      return @{ kDOUShareLibErrorInfoKeyReason: description ? description : @"request failed",
                kDOUShareLibErrorInfoKeyAPIErrorCode: errorCodeObj };
    }
  } else {
    DOUSNSSharingErrorLog(@"error string is not dictionary: %@", responseStr);
  }
  return nil;
}

#pragma mark - util method
- (void)setAccessTokenToRequest:(NSMutableURLRequest *)request token:(NSString *)token
{
  [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}

- (BOOL)fillCredentailWithResponseText:(NSString *)responseString
{
  NSDictionary *dic = [DOUSNSSharingUtil objectFromJSONString:responseString];
  DOUSNSSharingDebugLog(@"succeed to get accesstoken");
  NSString *accessToken = [dic objectForKey:@"access_token"];
  if (accessToken) {
    NSString *refrehtoken = [dic objectForKey:kOAuthv2RefreshToken];
    NSDate *expiresDate = [NSDate dateFromExpiresin:[dic objectForKey:@"expires_in"]];
    NSString *name = [dic objectForKey:@"douban_user_name"];
    [self.credential setAccessToken:accessToken
                        expiresDate:expiresDate
                             userid:nil
                           userName:name
                       refreshToken:refrehtoken];
    return YES;
  } else {
    return NO;
  }
}

- (void)fillMultipleFormData:(id<DOUMultipartFormData>)formData withStatus:(NSString *)text image:(UIImage *)image
{
  if (text) {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [formData appendPartWithFormData:data name:@"text"];
  }
  if (image) {
    NSData *data = UIImageJPEGRepresentation(image, .8f);
    [formData appendPartWithFileData:data name:@"image" fileName:@"iPhoneImage" mimeType:@"image/jpeg"];
  }
}

@end
