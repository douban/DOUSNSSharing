//
//  DOUMultipartFormData.m
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUMultipartFormData.h"

#pragma mark -

static NSString *const kDOUMultipartTemporaryFileDirectoryName = @"com.alamofire.uploads";

static NSString * DOUMultipartTemporaryFileDirectoryPath()
{
  static NSString *multipartTemporaryFilePath = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    multipartTemporaryFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:kDOUMultipartTemporaryFileDirectoryName] copy];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:multipartTemporaryFilePath withIntermediateDirectories:YES attributes:nil error:&error]) {
      DOUSNSSharingErrorLog(@"Failed to create multipart temporary file directory at %@", multipartTemporaryFilePath);
    }
  });
  
  return multipartTemporaryFilePath;
}

static NSString *const kDOUMultipartFormBoundary = @"Boundary+0xAbCdEfGbOuNdArY";

static NSString *const kDOUMultipartFormCRLF = @"\r\n";

static inline NSString * DOUMultipartFormInitialBoundary()
{
  return [NSString stringWithFormat:@"--%@%@", kDOUMultipartFormBoundary, kDOUMultipartFormCRLF];
}

static inline NSString * DOUMultipartFormEncapsulationBoundary()
{
  return [NSString stringWithFormat:@"%@--%@%@", kDOUMultipartFormCRLF, kDOUMultipartFormBoundary, kDOUMultipartFormCRLF];
}

static inline NSString * DOUMultipartFormFinalBoundary()
{
  return [NSString stringWithFormat:@"%@--%@--%@", kDOUMultipartFormCRLF, kDOUMultipartFormBoundary, kDOUMultipartFormCRLF];
}

@interface DOUMultipartFormData ()
@property (readwrite, nonatomic, retain) NSMutableURLRequest *request;
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@property (readwrite, nonatomic, retain) NSOutputStream *outputStream;
@property (readwrite, nonatomic, copy) NSString *temporaryFilePath;
@end

@implementation DOUMultipartFormData
@synthesize request = _request;
@synthesize stringEncoding = _stringEncoding;
@synthesize outputStream = _outputStream;
@synthesize temporaryFilePath = _temporaryFilePath;

- (id)initWithURLRequest:(NSMutableURLRequest *)request
          stringEncoding:(NSStringEncoding)encoding
{
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.request = request;
  self.stringEncoding = encoding;
  
  self.temporaryFilePath = [DOUMultipartTemporaryFileDirectoryPath() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
  self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.temporaryFilePath append:NO];
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [self.outputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
  [self.outputStream open];
  
  return self;
}

- (NSMutableURLRequest *)requestByFinalizingMultipartFormData
{
  // Close the stream and return the original request if no data has been written
  if ([[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] integerValue] == 0) {
    [self.outputStream close];
    
    return self.request;
  }
  
  [self appendData:[DOUMultipartFormFinalBoundary() dataUsingEncoding:self.stringEncoding]];
  
  [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kDOUMultipartFormBoundary] forHTTPHeaderField:@"Content-Type"];
  [self.request setValue:[[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] stringValue] forHTTPHeaderField:@"Content-Length"];
  [self.request setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:self.temporaryFilePath]];
  
  [self.outputStream close];
  
  return self.request;
}

#pragma mark - DOUMultipartFormData

- (void)appendBoundary
{
  if ([[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] integerValue] == 0) {
    [self appendString:DOUMultipartFormInitialBoundary()];
  } else {
    [self appendString:DOUMultipartFormEncapsulationBoundary()];
  }
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         body:(NSData *)body
{
  [self appendBoundary];
  
  for (NSString *field in [headers allKeys]) {
    [self appendString:[NSString stringWithFormat:@"%@: %@%@", field, [headers valueForKey:field], kDOUMultipartFormCRLF]];
  }
  
  [self appendString:kDOUMultipartFormCRLF];
  [self appendData:body];
}

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name
{
  NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
  [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
  
  [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
{
  NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
  [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
  [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
  
  [self appendPartWithHeaders:mutableHeaders body:data];
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError **)error
{
  if (![fileURL isFileURL]) {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:fileURL forKey:NSURLErrorFailingURLErrorKey];
    [userInfo setValue:NSLocalizedString(@"Expected URL to be a file URL", nil) forKey:NSLocalizedFailureReasonErrorKey];
    if (error != NULL) {
      *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
    }
    
    return NO;
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
  
  NSURLResponse *response = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
  
  if (data && response) {
    [self appendPartWithFileData:data name:name fileName:[response suggestedFilename] mimeType:[response MIMEType]];
    
    return YES;
  } else {
    return NO;
  }
}

- (void)appendString:(NSString *)string
{
  [self appendData:[string dataUsingEncoding:self.stringEncoding]];
}

- (void)appendData:(NSData *)data
{
  if ([data length] == 0) {
    return;
  }
  
  if ([self.outputStream hasSpaceAvailable]) {
    const uint8_t *dataBuffer = (uint8_t *)[data bytes];
    [self.outputStream write:&dataBuffer[0] maxLength:[data length]];
  }
}

@end
