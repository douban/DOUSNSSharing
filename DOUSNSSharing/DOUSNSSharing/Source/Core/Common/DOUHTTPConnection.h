//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUMultipartFormData.h"

@interface DOUHTTPConnection : NSObject

@property (nonatomic, copy, readonly) NSString *requestURL;
@property (nonatomic, strong, readonly) NSMutableData *buf;
@property (nonatomic, assign) NSTimeInterval connectionTimeout;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, strong, readonly) NSError *error;

- (void)sendRequeset:(NSURLRequest *)request
             finished:(void (^)(DOUHTTPConnection *conn))completedBlock
             failure:(void (^)(DOUHTTPConnection *conn))failureBlock;

- (NSString *)responseString;

- (void)cancelConnectionAndClearBlocks;

#pragma mark create http request
- (NSMutableURLRequest *)requestWithGetMethodForPath:(NSString *)path
                                          parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)requestWithPostMethodForPath:(NSString *)path
                                           parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)multipartFormRequestWithPostMethodForPath:(NSString *)path
                                                        parameters:(NSDictionary *)parameters
                                         constructingBodyWithBlock:(void (^)(id <DOUMultipartFormData> formData))block;

@end
