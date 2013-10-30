//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderAPIResponse.h"

@interface DOUVenderAPIResponse ()
@property (nonatomic, readwrite, strong) NSString *responseString;
@end

@implementation DOUVenderAPIResponse

- (id)initWithResponse:(NSString *)responseString
{
  self = [super init];
  if (self) {
    self.responseString = responseString;
  }
  return self;
}

@end
