//
//  NSMutableData+String.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "NSMutableData+String.h"

@implementation NSMutableData (String)

- (void)appendString:(NSString *)string
{
  [self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
