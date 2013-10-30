//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUVenderUserInfo.h"
#import "DOUOAuth2Credential.h"
#import "DOUVenderPost.h"

@interface DOUVenderAPIResponse : NSObject
@property (nonatomic, readonly, strong) NSString *responseString;
@property (nonatomic, strong) DOUOAuth2Credential *venderOAuth2Credential;
@property (nonatomic, strong) DOUVenderUserInfo * venderUserInfo;
@property (nonatomic, strong) DOUVenderPost * venderPostObject;

- (id)initWithResponse:(NSString *)responseString;
@end
