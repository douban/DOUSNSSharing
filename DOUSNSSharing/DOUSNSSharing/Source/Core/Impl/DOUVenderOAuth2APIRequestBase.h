//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DOUHTTPConnection.h"
#import "DOUOAuth2Credential.h"
#import "DOUVenderAPIResponse.h"
#import "DOUVenderPost.h"
#import "DOUVenderUserInfo.h"
#import "DOUVenderOAuth2APIRequestProtocol.h"
#import "DOUSharingLibConstants.h"

@interface DOUVenderOAuth2APIRequestBase : NSObject

@property (nonatomic, strong) DOUHTTPConnection * requestConnection;
@property (nonatomic, copy, readonly) DOUOAuth2RequestDidSucceedBlock didSucceedBlock;
@property (nonatomic, copy, readonly) DOUOAuth2RequestDidCancelBlock didCancelBlock;
@property (nonatomic, copy, readonly) DOUOAuth2RequestDidFailBlock didFailBlock;

@property (nonatomic, copy, readonly) DOUOAuth2Credential * credential;

- (id)initWithCredentail:(DOUOAuth2Credential *)crendential;
- (void)setDidSucceedBlock:(DOUOAuth2RequestDidSucceedBlock)didSucceedBlock
              didFailBlock:(DOUOAuth2RequestDidFailBlock)didFailBlock
            didCancelBlock:(DOUOAuth2RequestDidCancelBlock)didCancelBlock;
- (void)cancelAndClearBlocks;

#pragma mark -
- (void)sendHttpRequest:(NSURLRequest *)request;
- (void)httpRequestDidFinish:(DOUHTTPConnection *)conn;

#pragma mark - template methods, should be implemented in sub classes
- (NSDictionary *)errorDicFromRequestResponse:(NSString *)responseStr
                                    errorCode:(DOUShareLibRequestError *) errorCode;

#pragma mark - util
- (void)failWithSNSShareLibError:(DOUShareLibRequestError)errorCode reason:(NSString *)failReason;
- (void)failWithSNSShareLibError:(DOUShareLibRequestError)errorCode errorInfoDic:(NSDictionary *)errorDic;
@end
