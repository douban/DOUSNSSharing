//
//  DOUTencentWeiboOAuth2APIRequest.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUTencentWeiboOAuth2APIRequest.h"
#import "DOUVenderPost+TencentWeibo.h"
#import "DOUVenderUserInfo+TencentWeibo.h"
#import "NSDate+ExpiresIn.h"

static NSString *const kDOUTencentWeiboOAuth2APIRequestErrorDomain = @"DOUTencentWeiboOAuth2APIRequestError";

@implementation DOUTencentWeiboOAuth2APIRequest {
  DOUVenderAPIRequestType _requestType;
  DOUVenderAPIResponse *_responseObject;
}

- (BOOL)sendStatus:(NSString *)status
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  
  if (status) {
    _requestType = kDOUVenderAPIRequestTypeSendStatus;
    NSString *urlString = @"https://open.t.qq.com/api/t/add";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:8];
    [parameters setObject:status forKey:@"content"];
    [parameters addEntriesFromDictionary:[self commonRequestParameters]];
    
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
    [self sendHttpRequest:req];
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)sendStatus:(NSString *)status withImage:(UIImage *)image extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  if (image) {
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImage;
    NSString *urlString = @"https://open.t.qq.com/api/t/add_pic";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:status forKey:@"content"];
    [parameters addEntriesFromDictionary:[self commonRequestParameters]];
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSMutableURLRequest *req = [self.requestConnection
                                multipartFormRequestWithPostMethodForPath:urlString
                                parameters:parameters
                                constructingBodyWithBlock:^(id < DOUMultipartFormData > formData) {
                                  if (image) {
                                    NSData *data = UIImageJPEGRepresentation(image, .8f);
                                    [formData appendPartWithFileData:data name:@"pic" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                  }
                                }];
    [self sendHttpRequest:req];
    return YES;
  } else {
    return [self sendStatus:status extraOptions:options];
  }
}

- (BOOL)sendStatus:(NSString *)status withImageUrl:(NSString *)url extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  
  if (status) {
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImageUrl;
    NSString *urlString = @"https://open.t.qq.com/api/t/add_pic_url";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:10];
    [parameters setObject:status forKey:@"content"];
    [parameters setObject:url forKey:@"pic_url"];
    [parameters addEntriesFromDictionary:[self commonRequestParameters]];
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
    [self sendHttpRequest:req];
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)getAccessTokenWithCode:(NSString *)code redirectUri:(NSString *)uri
{
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:5];
  [parameters setObject:kOAuthv2GrantTypeAuthorizationCode forKey:kOAuthv2GrantType];
  [parameters setObject:code forKey:kOAuthv2AuthorizationCode];
  [parameters setObject:uri forKey:kOAuthv2RedirectURI];
  [parameters setObject:self.credential.apiKey forKey:kOAuthv2ClientId];
  [parameters setObject:self.credential.secret forKey:kOAuthv2ClientSecret];
  
  _requestType = kDOUVenderAPIRequestTypeGetAccessToken;
  NSString *urlString = @"https://open.t.qq.com/cgi-bin/oauth2/access_token";
  self.requestConnection = [[DOUHTTPConnection alloc] init];
  NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
  [self sendHttpRequest:req];
  return YES;
}

- (BOOL)getUserInfo
{
  @try {
    if (self.credential.accessToken) {
      _requestType = kDOUVenderAPIRequestTypeGetUserInfo;
      
      NSString *urlString = @"https://open.t.qq.com/api/user/info";
      NSDictionary *parameters = [self commonRequestParameters];
      self.requestConnection = [[DOUHTTPConnection alloc] init];
      NSMutableURLRequest *req = [self.requestConnection requestWithGetMethodForPath:urlString parameters:parameters];
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
        [post setValuesFromJSONStrForTencentWeibo:responseJSONStr];
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
        [userInfo setValuesFromJSONStrForTencentWeibo:responseJSONStr];
        _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
        _responseObject.venderUserInfo = userInfo;
      }
        break;
      default:
        break;
    }
  }
  return _responseObject;
}

#pragma mark - util method

- (NSDictionary *)commonRequestParameters
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
          @"json", @"format",
          self.credential.accessToken, kOAuthv2AccessToken,
          self.credential.apiKey, @"oauth_consumer_key",
          self.credential.openid, @"openid",
          @"2.a", @"oauth_version", nil];
}

- (BOOL)fillCredentailWithResponseText:(NSString *)responseString
{
  NSDictionary *dic = [responseString decodedUrlencodedParameters];
  DOUSNSSharingDebugLog(@"succeed to get accesstoken");
  
  NSString *accessToken = [dic objectForKey:@"access_token"];
  if (accessToken) {
    NSString *refrehtoken = [dic objectForKey:kOAuthv2RefreshToken];
    NSDate *expiresDate = [NSDate dateFromExpiresin:[dic objectForKey:@"expires_in"]];
    NSString *name = [dic objectForKey:@"name"];
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

- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *)errCode
{
  NSDictionary *response = [DOUSNSSharingUtil objectFromJSONString:responseStr];
  if (IS_INSTANCE_OF(response, NSDictionary)) {
    NSString *returnCodeStr = [response objectForKey:@"ret"];
    if ([returnCodeStr integerValue] != 0) {
      if ([returnCodeStr integerValue] == 3) {
        *errCode = kDOUShareLibRequestErrorOAuthInvalid;
      } else {
        *errCode = kDOUShareLibRequestErrorVenderServiceError;
      }
      NSString *errorCodeStr = [response objectForKey:@"errcode"];
      NSString *reason = [response objectForKey:@"msg"];
      DOUSNSSharingErrorLog(@"ret:%@; error:%@, message:%@", returnCodeStr, errorCodeStr, reason);
      NSString *errorIndentity = [NSString stringWithFormat:@"%@_%@", returnCodeStr, errorCodeStr];
      return @{ kDOUShareLibErrorInfoKeyReason: reason ? reason : @"请求失败",
                kDOUShareLibErrorInfoKeyAPIErrorCode: errorIndentity };
    }
  } else {
    DOUSNSSharingErrorLog(@"error string is not dictionary: %@", responseStr);
  }
  return nil;
}

@end
