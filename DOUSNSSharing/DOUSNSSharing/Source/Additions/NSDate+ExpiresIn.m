//
//  NSDate+ExpiresIn.m
//  SharingRequest
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "NSDate+ExpiresIn.h"

@implementation NSDate (ExpiresIn)

+ (NSDate *)dateFromExpiresin:(NSString *)expiresin
{
  NSDate *date = nil;
  NSTimeInterval time = [expiresin doubleValue];
  date = [NSDate dateWithTimeIntervalSinceNow:time];
  return date;
}

+ (NSDate *)dateFromExpiresTimestamp:(NSNumber *)timestamp
{
  NSTimeInterval t = [timestamp doubleValue];
  return [NSDate dateWithTimeIntervalSince1970:t];
}

- (NSNumber *)expiresTimestamp
{
  NSTimeInterval t = [self timeIntervalSince1970];
  return [NSNumber numberWithDouble:t];
}

@end
