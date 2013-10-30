//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

@implementation DOUSNSSharingUtil

+ (id)objectFromJSONString:(NSString *)jsonString
{
  if (jsonString == nil) {
    return nil;
  }
  NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err = nil;
  return [NSJSONSerialization JSONObjectWithData:jsonData
                                         options:NSJSONReadingMutableContainers
                                           error:&err];
}

@end
