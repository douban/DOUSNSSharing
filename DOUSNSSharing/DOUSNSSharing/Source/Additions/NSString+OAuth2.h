//
//  NSString+URL.h
//  SharingRequest
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//


@interface NSString (OAuth2)

- (NSString *)requestImplicitGrantUrlStringByAddingClientId:(NSString *)client_id
                                                redirectURI:(NSString *)redirect_uri
                                                      scope:(NSString *)scope
                                                      state:(NSString *)state;

- (NSString *)requestAuthorizationCodeUrlStringByAddingClientId:(NSString *)client_id
                                                    redirectURI:(NSString *)redirect_uri
                                                          scope:(NSString *)scope
                                                          state:(NSString *)state;

- (NSString *)URLStringByAddingParameters:(NSDictionary *)parameters;

- (NSString *)urlencodedString;

- (NSDictionary *)decodedUrlencodedParameters;

- (NSDictionary *)queryParameters;

- (NSString *)host;

@end
