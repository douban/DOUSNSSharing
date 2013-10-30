//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DOUVenderAPIRequestOptions : NSObject

@property (nonatomic, strong) NSString * renrenStatusLinkURL;
@property (nonatomic, strong) NSString * renrenStatusTitle;
@property (nonatomic, strong) NSString * renrenStatusDescription;

+ (DOUVenderAPIRequestOptions *)renrenOptionsWithStatusLink:(NSString *)statusURL
                                                      title:(NSString *)title
                                                description:(NSString *)desc;

@end
