//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderAPIRequestManager.h"
#import "DOUVenderOAuth2ImplFactory.h"

@interface DOUVenderAPIRequestManager ()
@property (nonatomic, copy) DOUOAuthAPIFinishBlock didFinishBlock;
@property (nonatomic, copy) DOUOAuthAPIOneRequestSuccBlock didSendOneBlock;
@property (nonatomic, copy) DOUOAuthAPIOneRequestFailureBlock didFailOneBlock;
@end

@implementation DOUVenderAPIRequestManager {
  NSArray *_venderCredentials;
  NSMutableArray *_requestArr;
  NSInteger _totalCount;
  NSInteger _succeedCount;
  NSMutableArray *_credentialsForFailures;
}

- (void)dealloc
{
  [self cancelAllRequestWithFinishBlock:NULL];
}

- (id)initWithBlocksForDidFinishBlock:(DOUOAuthAPIFinishBlock)didFinishBlock
                      didSendOneBlock:(DOUOAuthAPIOneRequestSuccBlock)didSendOneBlock
                      didFailOneBlock:(DOUOAuthAPIOneRequestFailureBlock)didFailOneBlock
{
  self = [super init];
  if (self) {
    _requestArr = [NSMutableArray arrayWithCapacity:4];
    _credentialsForFailures = [NSMutableArray arrayWithCapacity:4];
    self.didFinishBlock = didFinishBlock;
    self.didSendOneBlock = didSendOneBlock;
    self.didFailOneBlock = didFailOneBlock;
  }
  return self;
}

- (void)setRequestingVenderCredentials:(NSArray *)credentials
{
  [self cancelAllRequestWithFinishBlock:NULL];
  _succeedCount = 0;
  _totalCount = credentials.count;
  [_credentialsForFailures removeAllObjects];
  _venderCredentials = credentials;
}

- (NSArray *)requestArrForExistingCredentials
{
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
  for (DOUOAuth2Credential *crendential in _venderCredentials) {
    id<DOUVenderOAuth2APIRequest> req = [DOUVenderOAuth2ImplFactory createReqeustByVenderCredential:crendential];
    if (req) {
      [arr addObject:req];
      
      [req setDidSucceedBlock:^(id < DOUVenderOAuth2APIRequest > request) {
        if (self.didSendOneBlock) {
          self.didSendOneBlock([request apiResponse]);
        }
        [_requestArr removeObject:request];
        ++_succeedCount;
        if ([_requestArr count] == 0 && self.didFinishBlock) {
          self.didFinishBlock(_totalCount, _succeedCount, _credentialsForFailures);
        }
      } didFailBlock:^(id<DOUVenderOAuth2APIRequest> request, NSError *error) {
        if (self.didFailOneBlock) {
          self.didFailOneBlock(error, crendential.venderType.integerValue);
        }
        if (request) {
          [_requestArr removeObject:request];
        }
        if ([_requestArr count] == 0 && self.didFinishBlock) {
          self.didFinishBlock(_totalCount, _succeedCount, _credentialsForFailures);
        }
      } didCancelBlock:NULL];
    }
  }
  return arr;
}

- (void)sendStatus:(NSString *)status
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  @try {
    [self setRequestingVenderCredentials:credentials];
    NSArray *reqArr = [self requestArrForExistingCredentials];
    for (id<DOUVenderOAuth2APIRequest> req in reqArr) {
      [req sendStatus:status extraOptions:options];
    }
    if (reqArr && [reqArr count]) {
      [_requestArr addObjectsFromArray:reqArr];
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
    NSError *error = [NSError errorWithDomain:@"DOUVenderAPIRequestManager"
                                         code:1
                                     userInfo:@{ @"exception": exception }];
    self.didFailOneBlock(error, kDOUOAuth2VenderAll);
  }
}

- (void)sendStatus:(NSString *)status
      withImageUrl:(NSString *)url
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  @try {
    if (status == nil || status.length == 0) {
      status = @"分享";
    }
    [self setRequestingVenderCredentials:credentials];
    NSArray *reqArr = [self requestArrForExistingCredentials];
    for (id<DOUVenderOAuth2APIRequest> req in reqArr) {
      [req sendStatus:status withImageUrl:url extraOptions:options];
    }
    if (reqArr && [reqArr count]) {
      [_requestArr addObjectsFromArray:reqArr];
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
    NSError *error = [NSError errorWithDomain:@"DOUVenderAPIRequestManager"
                                         code:1
                                     userInfo:@{ @"exception": exception }];
    self.didFailOneBlock(error, kDOUOAuth2VenderAll);
  }
}

- (void)sendStatus:(NSString *)status
         withImage:(UIImage *)image
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options
{
  @try {
    if (status == nil || status.length == 0) {
      status = @"分享";
    }
    [self setRequestingVenderCredentials:credentials];
    NSArray *reqArr = [self requestArrForExistingCredentials];
    for (id<DOUVenderOAuth2APIRequest> req in reqArr) {
      [req sendStatus:status withImage:image extraOptions:options];
    }
    if (reqArr && [reqArr count]) {
      [_requestArr addObjectsFromArray:reqArr];
    }
  } @catch (NSException *exception) {
    DOUSNSSharingErrorLog(@"exception : %@", exception);
    NSError *error = [NSError errorWithDomain:@"DOUVenderAPIRequestManager"
                                         code:1
                                     userInfo:@{ @"exception": exception }];
    self.didFailOneBlock(error, kDOUOAuth2VenderAll);
  }
}

- (void)cancelAllRequestWithFinishBlock:(DOUOAuthAPIFinishBlock)finishBlock
{
  for (id<DOUVenderOAuth2APIRequest> req in _requestArr) {
    [req cancelAndClearBlocks];
  }
  if ([_requestArr count]) {
    [_requestArr removeAllObjects];
    if (finishBlock) {
      finishBlock(_totalCount, _succeedCount, _credentialsForFailures);
    }
  }
}

@end
