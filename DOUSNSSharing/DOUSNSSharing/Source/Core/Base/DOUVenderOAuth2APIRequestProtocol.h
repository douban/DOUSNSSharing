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
#import "DOUVenderAPIRequestOptions.h"

typedef enum DOUVenderAPIRequestType {
  kDOUVenderAPIRequestTypeUnknow = 0,
  kDOUVenderAPIRequestTypeSendStatus = 1,
  kDOUVenderAPIRequestTypeSendStatusWithImage,
  kDOUVenderAPIRequestTypeSendStatusWithImageUrl,
  kDOUVenderAPIRequestTypeGetAccessToken,
  kDOUVenderAPIRequestTypeGetUserInfo,
} DOUVenderAPIRequestType;


@protocol DOUVenderOAuth2APIRequest;

typedef void (^DOUOAuth2RequestDidSucceedBlock)(id<DOUVenderOAuth2APIRequest> request);
typedef void (^DOUOAuth2RequestDidCancelBlock)(id<DOUVenderOAuth2APIRequest> request);
typedef void (^DOUOAuth2RequestDidFailBlock)(id<DOUVenderOAuth2APIRequest> request, NSError *error);

@protocol DOUVenderOAuth2APIRequest <NSObject>

- (void)setDidSucceedBlock:(DOUOAuth2RequestDidSucceedBlock)didSucceedBlock
              didFailBlock:(DOUOAuth2RequestDidFailBlock)didFailBlock
            didCancelBlock:(DOUOAuth2RequestDidCancelBlock)didCancelBlock;

/*
 Return Value: if request is sent
 */
- (BOOL)sendStatus:(NSString *)status extraOptions:(DOUVenderAPIRequestOptions *)options;
- (BOOL)sendStatus:(NSString *)status withImage:(UIImage *)image extraOptions:(DOUVenderAPIRequestOptions *)options;
- (BOOL)sendStatus:(NSString *)status withImageUrl:(NSString *)url extraOptions:(DOUVenderAPIRequestOptions *)options;

/*
 Return Value: if request is sent
 */
- (BOOL)getAccessTokenWithCode:(NSString *)code redirectUri:(NSString *)uri;
/*
 Return Value: if request is sent
 */
- (BOOL)getUserInfo;

- (void)cancelAndClearBlocks;

- (DOUVenderAPIResponse *)apiResponse;

#pragma mark -
- (void)sendHttpRequest:(NSURLRequest *)request;
- (void)httpRequestDidFinish:(DOUHTTPConnection *)conn;

@end

