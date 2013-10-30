//
//  NSMutableDictionary+Copy.m
//  SharingRequestDemo
//
//
//

#import "NSMutableDictionary+Copy.h"


@implementation NSMutableDictionary (Copy)

- (void)addDuplicatableObject:(id)object forKey:(id)key
{
  if (nil == object || nil == key) {
    @throw NSInvalidArgumentException;
  }
  id value = [self objectForKey:key];
  if (nil == value) {
    [self setObject:object forKey:key];
  } else {
    if (IS_INSTANCE_OF(value, NSCountedSet)) {
      [value addObject:object];
    } else if (IS_INSTANCE_OF(value, NSSet)) {
      NSCountedSet *set = [NSCountedSet setWithSet:value];
      [set addObject:object];
      [self setObject:set forKey:key];
    } else {
      NSCountedSet *set = [NSCountedSet setWithCapacity:2];
      [set addObject:value];
      [set addObject:object];
      [self setObject:set forKey:key];
    }
  }
}

@end
