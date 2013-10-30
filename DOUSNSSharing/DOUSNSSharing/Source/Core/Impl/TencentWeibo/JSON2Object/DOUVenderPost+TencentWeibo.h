//
//  DOUVenderPost+TencentWeibo.h
//  DoubanSNSSharing
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUVenderPost.h"

@interface DOUVenderPost (TencentWeibo)

- (void)setValuesFromJSONStrForTencentWeibo:(NSString *)jsonStr;

@end
