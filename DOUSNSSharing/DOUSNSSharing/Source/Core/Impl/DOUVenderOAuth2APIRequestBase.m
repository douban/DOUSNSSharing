//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderOAuth2APIRequestBase.h"

@interface DOUVenderOAuth2APIRequestBase ()
@property (nonatomic, copy, readwrite) DOUOAuth2Credential *credential;

@property (nonatomic, copy, readwrite) DOUOAuth2RequestDidSucceedBlock didSucceedBlock;
@property (nonatomic, copy, readwrite) DOUOAuth2RequestDidCancelBlock didCancelBlock;
@property (nonatomic, copy, readwrite) DOUOAuth2RequestDidFailBlock didFailBlock;

@end


@implementation DOUVenderOAuth2APIRequestBase

- (id)initWithCredentail:(DOUOAuth2Credential *)crendential
{
  self = [super init];
  if (self) {
    self.credential = crendential;
  }
  return self;
}

- (void)setDidSucceedBlock:(DOUOAuth2RequestDidSucceedBlock)didSucceedBlock
              didFailBlock:(DOUOAuth2RequestDidFailBlock)didFailBlock
            didCancelBlock:(DOUOAuth2RequestDidCancelBlock)didCancelBlock
{
  self.didSucceedBlock = didSucceedBlock;
  self.didFailBlock = didFailBlock;
  self.didCancelBlock = didCancelBlock;
}

- (void)cancelAndClearBlocks
{
  self.didFailBlock = nil;
  self.didSucceedBlock = nil;
  self.didCancelBlock = nil;
  [self.requestConnection cancelConnectionAndClearBlocks];
  self.requestConnection = nil;
}

#pragma mark -
- (void)sendHttpRequest:(NSURLRequest *)request
{
  [self.requestConnection sendRequeset:request
                              finished:^(DOUHTTPConnection *conn) {
                                [self httpRequestDidFinish:conn];
                              } failure:^(DOUHTTPConnection *conn) {
                                [self failWithSNSShareLibError:kDOUShareLibRequestErrorNetwork
                                                        reason:[self.requestConnection.error description]];
                              }];
}

- (void)httpRequestDidFinish:(DOUHTTPConnection *)conn
{
  NSInteger httpStatusCode = conn.response.statusCode;
  DOUShareLibRequestError errCode = kDOUShareLibRequestErrorNone;
  NSDictionary *errorDic = [self errorDicFromRequestResponse:self.requestConnection.responseString errorCode:&errCode];
  if (httpStatusCode >= 200 && httpStatusCode < 300) {
    if (errCode != kDOUShareLibRequestErrorNone) {
      [self failWithSNSShareLibError:errCode errorInfoDic:errorDic];
    } else if (self.didSucceedBlock) {
      self.didSucceedBlock((id)self);
    }
  } else {
    if (errCode != kDOUShareLibRequestErrorNone) {
      [self failWithSNSShareLibError:errCode errorInfoDic:errorDic];
    } else {
      NSDictionary *errorDic = @{ kDOUShareLibErrorInfoKeyReason: @"请求失败",
                                  kDOUShareLibErrorInfoKeyAPIErrorCode: [NSString stringWithFormat:@"%ld", (long)httpStatusCode],
                                  @"type": @"http" };
      [self failWithSNSShareLibError:kDOUShareLibRequestErrorVenderServiceError
                        errorInfoDic:errorDic];
    }
  }
}

#pragma mark - template methods
- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *)errorCode
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark - util
- (void)failWithSNSShareLibError:(DOUShareLibRequestError)errorCode reason:(NSString *)failReason
{
  DOUSNSSharingWarnLog(@"Request failed, error code : %d vender : %@.", errorCode, self.credential.venderType);
  if (self.didFailBlock) {
    NSDictionary *errDic = failReason ? nil : @{ kDOUShareLibErrorInfoKeyReason: failReason };
    self.didFailBlock((id)self, [NSError errorWithDomain:kDOUShareLibErrorDomain
                                                    code:errorCode
                                                userInfo:errDic]);
  }
}

- (void)failWithSNSShareLibError:(DOUShareLibRequestError)errorCode errorInfoDic:(NSDictionary *)errorDic
{
  DOUSNSSharingWarnLog(@"Request error code : %d vender : %@, info : %@.", errorCode, self.credential.venderType, errorDic);
  if (self.didFailBlock) {
    self.didFailBlock((id)self, [NSError errorWithDomain:kDOUShareLibErrorDomain
                                                    code:errorCode
                                                userInfo:errorDic]);
  }
}

@end