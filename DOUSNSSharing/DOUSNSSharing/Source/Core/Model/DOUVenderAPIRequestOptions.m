//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderAPIRequestOptions.h"

@implementation DOUVenderAPIRequestOptions

+ (DOUVenderAPIRequestOptions *)renrenOptionsWithStatusLink:(NSString *)statusURL
                                                      title:(NSString *)title
                                                description:(NSString *)desc
{
  DOUVenderAPIRequestOptions *options = [[DOUVenderAPIRequestOptions alloc] init];
  options.renrenStatusLinkURL = statusURL;
  options.renrenStatusTitle = title;
  options.renrenStatusDescription = desc;
  return options;
}

@end
