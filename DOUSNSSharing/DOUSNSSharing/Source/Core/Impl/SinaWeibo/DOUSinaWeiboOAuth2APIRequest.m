//
//  DOUSinaWeiboOAuth2APIRequest.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUSinaWeiboOAuth2APIRequest.h"
#import "DOUVenderPost+SinaWeibo.h"
#import "DOUVenderUserInfo+SinaWeibo.h"
#import "NSDate+ExpiresIn.h"
#import "DOUSharingLibConstants.h"

static NSString *const kDOUSinaWeiboOAuth2APIRequestErrorDomain = @"DOUSinaWeiboOAuth2APIRequestError";

@implementation DOUSinaWeiboOAuth2APIRequest {
  DOUVenderAPIRequestType _requestType;
  DOUVenderAPIResponse *_responseObject;
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
    NSString *urlString = @"https://api.weibo.com/2/statuses/update.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:status forKey:@"status"];
    [parameters setObject:self.credential.accessToken forKey:kOAuthv2AccessToken];
    
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
    [self sendHttpRequest:req];
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)sendStatus:(NSString *)status
         withImage:(UIImage *)image
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  if (status == nil) {
    DOUSNSSharingErrorLog(DOU_LIB_ERROR_INVALID_PARAM);
    [self failWithSNSShareLibError:kDOUShareLibRequestErrorInvalidParam
                            reason:DOU_LIB_ERROR_INVALID_PARAM];
    return NO;
  }
  
  if (image) {
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImage;
    NSString *urlString = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:self.credential.accessToken forKey:kOAuthv2AccessToken];
    [parameters setObject:status forKey:@"status"];
    self.requestConnection = [[DOUHTTPConnection alloc] init];
    NSMutableURLRequest *req = [self.requestConnection
                                multipartFormRequestWithPostMethodForPath:urlString
                                parameters:parameters
                                constructingBodyWithBlock:^(id < DOUMultipartFormData > formData) {
                                  [self fillMultipleFormData:formData withStatus:status image:image];
                                }];
    [self sendHttpRequest:req];
    return YES;
  } else {
    return [self sendStatus:status extraOptions:options];
  }
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
    NSString *urlString = @"https://api.weibo.com/2/statuses/upload_url_text.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:status forKey:@"status"];
    [parameters setObject:self.credential.accessToken forKey:kOAuthv2AccessToken];
    [parameters setObject:url forKey:@"url"];
    _requestType = kDOUVenderAPIRequestTypeSendStatusWithImageUrl;
    
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
  NSString *urlString = @"https://api.weibo.com/oauth2/access_token";
  self.requestConnection = [[DOUHTTPConnection alloc] init];
  NSURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
  [self sendHttpRequest:req];
  return YES;
}

- (BOOL)getUserInfo
{
  @try {
    if (self.credential.accessToken && self.credential.userid) {
      NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
      [parameters setObject:self.credential.userid forKey:@"uid"];
      
      NSString *urlString = @"https://api.weibo.com/2/users/show.json";
      NSString *authorization = [NSString stringWithFormat:@"OAuth2 %@", self.credential.accessToken];
      NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:authorization, @"Authorization", nil];
      _requestType = kDOUVenderAPIRequestTypeGetUserInfo;
      self.requestConnection = [[DOUHTTPConnection alloc] init];
      NSMutableURLRequest *req = [self.requestConnection requestWithGetMethodForPath:urlString parameters:parameters];
      [req setAllHTTPHeaderFields:headers];
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
        [post setValuesFromJSONStrForSinaWeibo:responseJSONStr];
        _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
        _responseObject.venderPostObject = post;
      }
        break;
      case kDOUVenderAPIRequestTypeGetAccessToken: {
        [self fillCredentailWithResponseDic:[DOUSNSSharingUtil objectFromJSONString:responseJSONStr]];
        _responseObject = [[DOUVenderAPIResponse alloc] initWithResponse:responseJSONStr];
        _responseObject.venderOAuth2Credential = self.credential;
        break;
      }
      case kDOUVenderAPIRequestTypeGetUserInfo: {
        DOUVenderUserInfo *userInfo = [[DOUVenderUserInfo alloc] init];
        [userInfo setValuesFromJSONStrForSinaWeibo:responseJSONStr];
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

- (void)fillMultipleFormData:(id<DOUMultipartFormData>)formData withStatus:(NSString *)status image:(UIImage *)image
{
  if (status) {
    NSData *data = [status dataUsingEncoding:NSUTF8StringEncoding];
    [formData appendPartWithFormData:data name:@"status"];
  }
  if (image) {
    NSData *data = UIImageJPEGRepresentation(image, .8f);
    [formData appendPartWithFileData:data name:@"pic" fileName:@"image.jpg" mimeType:@"image/jpeg"];
  }
}

- (BOOL)fillCredentailWithResponseDic:(NSDictionary *)dic
{
  NSString *accessToken = [dic objectForKey:@"access_token"];
  if (accessToken) {
    NSDate *expiresDate = [NSDate dateFromExpiresin:[dic objectForKey:@"expires_in"]];
    NSString *userid = nil;
    id content = [dic objectForKey:@"uid"];
    if (IS_INSTANCE_OF(content, NSString)) {
      userid = content;
    } else if (IS_INSTANCE_OF(content, NSNumber)) {
      userid = [NSString stringWithFormat:@"%d", [content unsignedIntValue]];
    }
    [self.credential setAccessToken:accessToken expiresDate:expiresDate userid:userid];
    return YES;
  } else {
    return NO;
  }
}

- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *)errCode
{
  @try {
    NSDictionary *response = [DOUSNSSharingUtil objectFromJSONString:responseStr];
    if (IS_INSTANCE_OF(response, NSDictionary)) {
      NSString *errorCode = [response objectForKey:@"error_code"];
      if (errorCode) {
        NSInteger weiboErrorCode = [errorCode integerValue];
        // OAuth 错误码的区间
        if (weiboErrorCode >= 21301 && weiboErrorCode <= 21334) {
          *errCode = kDOUShareLibRequestErrorOAuthInvalid;
        } else {
          *errCode = kDOUShareLibRequestErrorVenderServiceError;
        }
        NSInteger code = [errorCode integerValue];
        DOUSNSSharingErrorLog(@"error:%@", response);
        NSString *reason = [response objectForKey:@"error"];
        NSString *request = [response objectForKey:@"request"];
        DOUSNSSharingErrorLog(@"error:%@; request:%@, code:%ld.", reason, request, (long)code);
        return @{ kDOUShareLibErrorInfoKeyReason: reason,
                  kDOUShareLibErrorInfoKeyAPIErrorCode: errorCode };
      }
    } else {
      DOUSNSSharingErrorLog(@"error string is not dictionary: %@", responseStr);
    }
    return nil;
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@ ", exception);
    return nil;
  }
}

@end
