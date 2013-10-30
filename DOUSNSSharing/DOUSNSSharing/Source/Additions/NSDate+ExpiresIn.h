//
//  NSDate+ExpiresIn.h
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ExpiresIn)
+ (NSDate *)dateFromExpiresin:(NSString *)expiresin;
+ (NSDate *)dateFromExpiresTimestamp:(NSNumber *)timestamp;
- (NSNumber *)expiresTimestamp;
@end
