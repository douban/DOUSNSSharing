//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//
#import "DOUSNSAutoCodingObject.h"
#import <objc/runtime.h>

@implementation DOUSNSAutoCodingObject

- (void)setObjectValueForIVar:(Ivar)ivar forObject:(id)obj withCoder:(NSCoder *)coder
{
  NSString *ivarNameStr = [NSString stringWithCString:ivar_getName(ivar) encoding:NSASCIIStringEncoding];
  id value = [coder decodeObjectForKey:ivarNameStr];
  if (value == nil) {
    return;
  }
  object_setIvar(self, ivar, value);
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self != nil) {
    Class clazz = [self class];
    while (clazz) {
      if (clazz == [NSObject class]) {
        break;
      }
      u_int count;
      Ivar *ivars = class_copyIvarList(clazz, &count);
      for (int i = 0; i < count; i++) {
        [self setObjectValueForIVar:ivars[i] forObject:self withCoder:coder];
      }
      free(ivars);
      clazz = [clazz superclass];
    }
  }
  
  return self;
}

- (id)getObjectValueFromIVar:(Ivar)ivar
{
  id value = object_getIvar(self, ivar);
  return value;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  Class clazz = [self class];
  while (clazz) {
    if (clazz == [NSObject class]) {
      break;
    }
    u_int count;
    Ivar *ivars = class_copyIvarList(clazz, &count);
    for (int i = 0; i < count; i++) {
      NSString *ivarNameStr = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSASCIIStringEncoding];
      
      [coder encodeObject:[self getObjectValueFromIVar:ivars[i]]
                   forKey:ivarNameStr];
    }
    free(ivars);
    clazz = [clazz superclass];
  }
}

@end
