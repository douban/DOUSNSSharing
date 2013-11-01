//
//  AppGlobal.h
//  SharingRequestDemo
//
//
//

#import <Foundation/Foundation.h>
#import "DOUOAuth2Credential.h"

@interface AppGlobal : NSObject

@property (nonatomic, strong) DOUOAuth2Credential *douban;
@property (nonatomic, strong) DOUOAuth2Credential *sinaWeibo;
@property (nonatomic, strong) DOUOAuth2Credential *renren;
@property (nonatomic, strong) DOUOAuth2Credential *tencentWeibo;

+ (AppGlobal *)sharedInstance;

- (NSArray *)allCredentials;

- (DOUOAuth2Credential *)credentialByVenderType:(DOUOAuth2VenderType)venderType;

@end
