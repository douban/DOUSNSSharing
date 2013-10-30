//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#import "DOUHTTPConnection.h"
#import "NSString+OAuth2.h"
#import "NSDictionary+URL.h"

const static NSTimeInterval kDOUHTTPConnectionTimeout = 20.0;

typedef void (^DOUHTTPConnectionBasicBlock)(DOUHTTPConnection *conn);


@interface DOUHTTPConnection ()
@property (nonatomic, copy, readwrite) NSString *requestURL;
@property (nonatomic, copy) DOUHTTPConnectionBasicBlock finishBlock;
@property (nonatomic, copy) DOUHTTPConnectionBasicBlock failureBlock;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong, readwrite) NSMutableData *buf;
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@end

@implementation DOUHTTPConnection

- (id)init
{
  self = [super init];
  if (self) {
    self.connectionTimeout = kDOUHTTPConnectionTimeout;
    self.stringEncoding = NSUTF8StringEncoding;
  }
  return self;
}

- (void)sendRequeset:(NSURLRequest *)request
            finished:(void (^)(DOUHTTPConnection *conn))completedBlock
             failure:(void (^)(DOUHTTPConnection *conn))failureBlock
{
  self.requestURL = request.URL.absoluteString;
  self.finishBlock = completedBlock;
  self.failureBlock = failureBlock;
  self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  self.buf = [NSMutableData data];
}

#pragma mark create http request
- (NSMutableURLRequest *)requestWithGetMethodForPath:(NSString *)path
                                          parameters:(NSDictionary *)parameters
{
  NSMutableString *urlMutableStr = [[NSMutableString alloc] initWithString:path];
  if ([parameters count]) {
    NSString *queryStr = nil;
    if ([urlMutableStr rangeOfString:@"?"].location == NSNotFound) {
      queryStr = [NSString stringWithFormat:@"?%@", [parameters queryString]];
    } else {
      queryStr = [NSString stringWithFormat:@"&%@", [parameters queryString]];
    }
    [urlMutableStr appendString:queryStr];
  }
  NSURL *url = [NSURL URLWithString:urlMutableStr];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"GET"];
  return request;
}

- (NSMutableURLRequest *)requestWithPostMethodForPath:(NSString *)path
                                           parameters:(NSDictionary *)parameters
{
  NSURL *url = [NSURL URLWithString:path];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"POST"];
  
  NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
  [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
  if ([parameters count]) {
    [request setHTTPBody:[[parameters queryString] dataUsingEncoding:self.stringEncoding]];
  }
  return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithPostMethodForPath:(NSString *)path
                                                        parameters:(NSDictionary *)parameters
                                         constructingBodyWithBlock:(void (^)(id <DOUMultipartFormData> formData))block
{
  NSURL *url = [NSURL URLWithString:path];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"POST"];
  __block DOUMultipartFormData *formData = [[DOUMultipartFormData alloc] initWithURLRequest:request
                                                                             stringEncoding:self.stringEncoding];
  if (parameters) {
    NSEnumerator *keyEnumerator = parameters.keyEnumerator;
    id key = [keyEnumerator nextObject];
    while (key) {
      id value = [parameters objectForKey:key];
      NSData *data = nil;
      if ([value isKindOfClass:[NSData class]]) {
        data = value;
      } else {
        data = [[value description] dataUsingEncoding:self.stringEncoding];
      }
      if (data) {
        [formData appendPartWithFormData:data name:[key description]];
      }
      key = [keyEnumerator nextObject];
    }
  }
  if (block) {
    block(formData);
  }
  return [formData requestByFinalizingMultipartFormData];
}

- (NSString *)responseString
{
  NSString *responseStr = [[NSString alloc] initWithData:self.buf encoding:NSUTF8StringEncoding];
  return responseStr;
}

- (void)cancelConnectionAndClearBlocks
{
  [self.connection cancel];
  self.connection = nil;
  self.finishBlock = nil;
  self.failureBlock = nil;
  self.buf = nil;
}

#pragma mark - util methods

- (void)handleWhenConnectionDidFinish
{
  if (self.error) {
    [self requestDidFail:self.error];
  } else if (self.response) {
    [self requestDidFinished];
  } else {
    [self requestDidFail:[NSError errorWithDomain:@"com.douban.DOUHTTPConnection"
                                             code:1
                                         userInfo:nil]];
  }
  self.connection = nil;
}

#pragma mark -
//
// NSURLConnection's delegate:
//
- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)aResponse
{
  NSHTTPURLResponse *response = (NSHTTPURLResponse *)aResponse;
  if (response) {
    DOUSNSSharingInfoLog(@"response code = %ld", (long)response.statusCode);
  }
  [self.buf setData:nil];
  self.response = response;
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
  [self.buf appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
  DOUSNSSharingWarnLog(@"Connection failed as error : %@", error);
  self.error = error;
  [self requestDidFail:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
  [self handleWhenConnectionDidFinish];
}

- (void)requestDidFinished
{
  DOUSNSSharingInfoLog(@"network connection did finish loading");
  if (self.finishBlock) {
    self.finishBlock(self);
  }
}

- (void)requestDidFail:(NSError *)error
{
  DOUSNSSharingWarnLog(@"error = %@", error);
  if (self.failureBlock) {
    self.failureBlock(self);
  }
}

@end
