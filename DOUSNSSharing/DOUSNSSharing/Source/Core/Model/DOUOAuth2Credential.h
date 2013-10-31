//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUSNSAutoCodingObject.h"
#import "DOUSharingLibConstants.h"

@interface DOUOAuth2Credential : DOUSNSAutoCodingObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *apiKey;
@property (nonatomic, readonly, copy) NSString *secret;
@property (nonatomic, readonly, copy) NSString *userid;
@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, readonly, copy) NSString *accessToken;
@property (nonatomic, readonly, copy) NSString *refreshToken;
@property (nonatomic, readonly, strong) NSDate *expiresDate;
@property (nonatomic, readonly, strong) NSNumber *venderType;

// openid and openkey are used in Tencent.
@property (nonatomic, readonly, copy) NSString * openid;
@property (nonatomic, readonly, copy) NSString * openkey;

- (id)initWithAPIKey:(NSString *)apiKey secret:(NSString *)secret venderType:(DOUOAuth2VenderType)type;
- (void)setAccessToken:(NSString *)accessToken expiresDate:(NSDate *)expiresDate;
- (void)setAccessToken:(NSString *)accessToken expiresDate:(NSDate *)expiresDate userid:(NSString *)userid;
- (void)setAccessToken:(NSString *)accessToken
           expiresDate:(NSDate *)expiresDate
                userid:(NSString *)userid
              userName:(NSString *)userName
          refreshToken:(NSString *)refreshToken;
- (void)setUserName:(NSString *)userName userID:(NSString *)userID;

- (void)setOpenid:(NSString *)openid openkey:(NSString *)openkey;
@end
