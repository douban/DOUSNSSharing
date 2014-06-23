//
//  DOURenrenOAuth2APIRequest.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOURenrenOAuth2APIRequest.h"
#import "DOUVenderPost+Renren.h"
#import "DOUVenderUserInfo+Renren.h"
#import "NSDate+ExpiresIn.h"

static NSString *const kDOURenrenAPIMethod = @"method";
static NSString *const kDOURenrenAPIV = @"v";
static NSString *const kDOURenrenAPIType = @"type";

static NSString *const kDOURenrenOAuth2APIRequestErrorDomain = @"DOURenrenOAuth2APIRequestError";

@implementation DOURenrenOAuth2APIRequest {
  DOUVenderAPIRequestType _requestType;
  DOUVenderAPIResponse *_responseObject;
}

- (BOOL)_sendStatus:(NSString *)status
           imageURL:(NSString *)imageURL
       extraOptions:(DOUVenderAPIRequestOptions *)options
{
  NSString *urlString = @"https://api.renren.com/v2/feed/put";
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:8];
  [parameters setObject:@"feed.publishFeed" forKey:kDOURenrenAPIMethod];
  [parameters setObject:status forKey:@"message"];
  if (imageURL) {
    [parameters setObject:imageURL forKey:@"imageUrl"];
  }
  
  if (options.renrenStatusDescription && options.renrenStatusDescription.length > 0) {
    [parameters setObject:options.renrenStatusDescription forKey:@"description"];
  } else {
    [parameters setObject:status forKey:@"description"];
  }
  if (options.renrenStatusTitle && options.renrenStatusTitle.length > 0) {
    [parameters setObject:options.renrenStatusTitle forKey:@"title"];
  } else {
    [parameters setObject:@"分享" forKey:@"title"];
  }
  if (options.renrenStatusLinkURL && options.renrenStatusLinkURL.length > 0) {
    [parameters setObject:options.renrenStatusLinkURL forKey:@"targetUrl"];
  } else {
    [parameters setObject:@"http://m.douban.com" forKey:@"targetUrl"];
  }
  self.requestConnection = [[DOUHTTPConnection alloc] init];
  NSMutableURLRequest *req = [self.requestConnection requestWithPostMethodForPath:urlString parameters:parameters];
  [self setOAuthHeaderForRequest:req];
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
    return [self _sendStatus:status imageURL:nil extraOptions:options];
  } else {
    return NO;
  }
}

- (BOOL)sendStatus:(NSString *)status
         withImage:(UIImage *)image
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  DOUSNSSharingWarnLog(@"Renren doesn't support fully with image");
  return [self sendStatus:status extraOptions:options];
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
    return [self _sendStatus:status imageURL:url extraOptions:options];
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
    NSString *urlString = @"https://graph.renren.com/oauth/token";
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
      NSString *urlString = @"https://api.renren.com/v2/user/get";
      self.requestConnection = [[DOUHTTPConnection alloc] init];
      NSMutableURLRequest *req = [self.requestConnection requestWithGetMethodForPath:urlString parameters:nil];
      [self setOAuthHeaderForRequest:req];
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
        [post setValuesFromJSONStrForRenren:responseJSONStr];
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
        NSDictionary *user = [[DOUSNSSharingUtil objectFromJSONString:responseJSONStr] objectForKey:@"response"];
        if (user && [user isKindOfClass:[NSDictionary class]]) {
          [userInfo setUserInfoFromJSONDicForRenren:user];
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

- (void)setOAuthHeaderForRequest:(NSMutableURLRequest *)request
{
  [request setValue:[@"Bearer " stringByAppendingString:self.credential.accessToken] forHTTPHeaderField:@"Authorization"];
}

- (BOOL)fillCredentailWithResponseText:(NSString *)responseString
{
  NSDictionary *dic = [DOUSNSSharingUtil objectFromJSONString:responseString];
  DOUSNSSharingDebugLog(@"succeed to get accesstoken");
  NSString *accessToken = [dic objectForKey:@"access_token"];
  if (accessToken) {
    NSString *refrehtoken = [dic objectForKey:kOAuthv2RefreshToken];
    NSDate *expiresDate = [NSDate dateFromExpiresin:[dic objectForKey:@"expires_in"]];
    [self.credential setAccessToken:accessToken
                        expiresDate:expiresDate
                             userid:nil
                           userName:dic[@"user"][@"name"]
                       refreshToken:refrehtoken];
    return YES;
  } else {
    return NO;
  }
}

- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *)errorCode
{
  NSDictionary *response = [DOUSNSSharingUtil objectFromJSONString:responseStr];
  if (IS_INSTANCE_OF(response, NSDictionary)) {
    id errorCodeObj = [response objectForKey:@"error_code"];
    //再试试另外一个key ： error
    if (errorCodeObj == nil) {
      errorCodeObj = [response objectForKey:@"error"];
    }
    if (errorCodeObj) {
      NSInteger renrenErrorCode = [errorCodeObj integerValue];
      
      if (renrenErrorCode == 303 || renrenErrorCode == 304 || renrenErrorCode == 250) {
        *errorCode = kDOUShareLibRequestErrorVenderServiceError;
      } else if ((renrenErrorCode >= 2000 && renrenErrorCode <= 3000)
                 || (renrenErrorCode >= 200 && renrenErrorCode <= 500)) {
        *errorCode = kDOUShareLibRequestErrorOAuthInvalid;
      } else {
        *errorCode = kDOUShareLibRequestErrorVenderServiceError;
      }
      DOUSNSSharingErrorLog(@"error:%@", response);
      NSString *description = [response objectForKey:@"error_msg"];
      if (description == nil) {
        description = [response objectForKey:@"error_description"];
      }
      return @{ kDOUShareLibErrorInfoKeyReason: description ? description : @"请求失败",
                kDOUShareLibErrorInfoKeyAPIErrorCode: errorCodeObj };
    }
  } else {
    DOUSNSSharingErrorLog(@"error string is not dictionary: %@", responseStr);
  }
  return nil;
}

@end
