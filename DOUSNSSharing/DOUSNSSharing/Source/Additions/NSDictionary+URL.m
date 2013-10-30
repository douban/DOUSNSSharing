//
//  NSDictionary+URL.m
//  SharingRequest
//
//
//
#import <Foundation/Foundation.h>

#import "NSDictionary+URL.h"
#import "NSString+OAuth2.h"



@implementation NSDictionary (URL)

- (NSString *)queryString
{
  NSMutableArray *parameterStrings = [NSMutableArray arrayWithCapacity:[self count]];
  for (NSString *key in self) {
    id value = [self valueForKey:key];
    if (IS_INSTANCE_OF(value, NSString)) {
      NSString *s = (NSString *)value;
      NSString *parameter;
      if ([s length] > 0) {             //may be only a value, but no name/key
        parameter = [NSString stringWithFormat:@"%@=%@",
                     [key urlencodedString], [s urlencodedString]];
      } else {
        parameter = [key urlencodedString];
      }
      [parameterStrings addObject:parameter];
    } else if (IS_INSTANCE_OF(value, NSNumber)) {
      NSNumber *v = (NSNumber *)value;
      NSString *parameter = [NSString stringWithFormat:@"%@=%@",
                             [key urlencodedString], [[v stringValue] urlencodedString]];
      [parameterStrings addObject:parameter];
    } else if (IS_INSTANCE_OF(value, NSSet)) {
      NSArray *set = (NSArray *)value;
      NSString *encodedKey = [key urlencodedString];
      for (NSString *s in set) {
        NSString *parameter;
        if ([s length] > 0) {                 //may be only a value, but no name/key
          parameter = [NSString stringWithFormat:@"%@=%@",
                       encodedKey, [s urlencodedString]];
        } else {
          parameter = encodedKey;
        }
        [parameterStrings addObject:parameter];
      }
    }
  }
  if ([parameterStrings count]) {
    return [parameterStrings componentsJoinedByString:@"&"];
  } else {
    return @"";
  }
}

@end
