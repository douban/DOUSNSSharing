//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUOAuth2Credential.h"

@interface DOUOAuth2Credential ()
@property (nonatomic, readwrite, copy) NSString *apiKey;
@property (nonatomic, readwrite, copy) NSString *secret;
@property (nonatomic, readwrite, copy) NSString *userid;
@property (nonatomic, readwrite, copy) NSString *userName;
@property (nonatomic, readwrite, copy) NSString *accessToken;
@property (nonatomic, readwrite, copy) NSString *refreshToken;
@property (nonatomic, readwrite, strong) NSDate *expiresDate;
@property (nonatomic, readwrite, strong) NSNumber *venderType;

@property (nonatomic, readwrite, copy) NSString *openid;
@property (nonatomic, readwrite, copy) NSString *openkey;

@end

@implementation DOUOAuth2Credential

- (id)copyWithZone:(NSZone *)zone
{
  DOUOAuth2Credential *copied = [[DOUOAuth2Credential allocWithZone:zone] init];
  copied.apiKey = self.apiKey;
  copied.secret = self.secret;
  copied.userid = self.userid;
  copied.accessToken = self.accessToken;
  copied.refreshToken = self.refreshToken;
  copied.expiresDate = [self.expiresDate copyWithZone:zone];
  copied.venderType = [self.venderType copyWithZone:zone];
  
  copied.openid = [self.openid copyWithZone:zone];
  copied.openkey = [self.openkey copyWithZone:zone];
  return copied;
}

- (id)initWithAPIKey:(NSString *)apiKey secret:(NSString *)secret venderType:(DOUOAuth2VenderType)type
{
  self = [super init];
  if (self) {
    self.apiKey = apiKey;
    self.secret = secret;
    self.venderType = [NSNumber numberWithInteger:type];
  }
  return self;
}

- (void)setAccessToken:(NSString *)accessToken expiresDate:(NSDate *)expiresDate
{
  self.accessToken = accessToken;
  self.expiresDate = expiresDate;
}

- (void)setAccessToken:(NSString *)accessToken expiresDate:(NSDate *)expiresDate userid:(NSString *)userid
{
  [self setAccessToken:accessToken expiresDate:expiresDate];
  self.userid = userid;
}

- (void)setAccessToken:(NSString *)accessToken
           expiresDate:(NSDate *)expiresDate
                userid:(NSString *)userid
              userName:(NSString *)userName
          refreshToken:(NSString *)refreshToken
{
  [self setAccessToken:accessToken expiresDate:expiresDate userid:userid];
  self.refreshToken = refreshToken;
  self.userName = userName;
}

- (void)setUserName:(NSString *)userName userID:(NSString *)userID
{
  self.userName = userName;
  self.userid = userID;
}

- (void)setOpenid:(NSString *)openid openkey:(NSString *)openkey
{
  self.openid = openid;
  self.openkey = openkey;
}

@end
