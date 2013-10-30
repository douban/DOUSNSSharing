//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DOUSharingLibConstants.h"
#import "DOUOAuth2Credential.h"
#import "DOUVenderAPIResponse.h"
#import "DOUVenderAPIRequestOptions.h"

typedef void (^DOUOAuthAPIFinishBlock)(NSInteger totalCount, NSInteger succeedCount, NSArray *credentialsForFailures);
typedef void (^DOUOAuthAPIOneRequestSuccBlock)(DOUVenderAPIResponse * resp);
typedef void (^DOUOAuthAPIOneRequestFailureBlock)(NSError *error, DOUOAuth2VenderType venderType);

@interface DOUVenderAPIRequestManager : NSObject

- (id)initWithBlocksForDidFinishBlock:(DOUOAuthAPIFinishBlock)didFinishBlock
                      didSendOneBlock:(DOUOAuthAPIOneRequestSuccBlock)didSendOneBlock
                      didFailOneBlock:(DOUOAuthAPIOneRequestFailureBlock)didFailOneBlock;

- (void)sendStatus:(NSString *)status
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options;

- (void)sendStatus:(NSString *)status
      withImageUrl:(NSString *)url
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options;

/*
 Send status with image.
 Renren doesn't support fully, send status only without image.
 */
- (void)sendStatus:(NSString *)status
         withImage:(UIImage *)image
   withCredentials:(NSArray *)credentials
      extraOptions:(DOUVenderAPIRequestOptions *)options;

- (void)cancelAllRequestWithFinishBlock:(DOUOAuthAPIFinishBlock)didFinishBlock;

@end
