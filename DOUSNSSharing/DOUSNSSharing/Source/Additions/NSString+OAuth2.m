//
//  NSString+URL.m
//  SharingRequest
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOUSharingLibConstants.h"
#import "NSString+OAuth2.h"
#import "NSDictionary+URL.h"
#import "NSMutableDictionary+Copy.h"

#define ESCAPE_CHARACTERS ":/?#[]@!$ &'()*+,;=\"<>%{}|\\^`"   //RFC3986, '~' is an unreserved character ,should not be escaped

@implementation NSString (OAuth2)

- (NSString *)URLStringByAddingParameters:(NSDictionary *)parameters
{
  NSString *newUrlString = [parameters queryString];
  if ([newUrlString length] > 0) {
    NSArray *songUrlParams = [self componentsSeparatedByString:@"?"];
    if ([songUrlParams count] > 1) {
      newUrlString = [self stringByAppendingFormat:@"&%@", newUrlString];
    } else {
      newUrlString = [self stringByAppendingFormat:@"?%@", newUrlString];
    }
    
    return newUrlString;
  }
  
  return self;
}

- (NSString *)requestImplicitGrantUrlStringByAddingClientId:(NSString *)client_id
                                                redirectURI:(NSString *)redirect_uri
                                                      scope:(NSString *)scope
                                                      state:(NSString *)state
{
  if (nil == client_id) {
    return nil;
  }
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:5];
  [parameters setObject:kOAuthv2ImplictGrant forKey:kOAuthv2ResponseType];
  [parameters setObject:client_id forKey:kOAuthv2ClientId];
  if (redirect_uri) {
    [parameters setObject:redirect_uri forKey:kOAuthv2RedirectURI];
  }
  if (scope) {
    [parameters setObject:scope forKey:kOAuthv2Scope];
  }
  if (state) {
    [parameters setObject:state forKey:kOAuthv2State];
  }
  
  return [self URLStringByAddingParameters:parameters];
}

- (NSString *)requestAuthorizationCodeUrlStringByAddingClientId:(NSString *)client_id
                                                    redirectURI:(NSString *)redirect_uri
                                                          scope:(NSString *)scope
                                                          state:(NSString *)state
{
  if (nil == client_id) {
    return nil;
  }
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:5];
  [parameters setObject:kOAuthv2AuthorizationCode forKey:kOAuthv2ResponseType];
  [parameters setObject:client_id forKey:kOAuthv2ClientId];
  if (redirect_uri) {
    [parameters setObject:redirect_uri forKey:kOAuthv2RedirectURI];
  }
  if (scope) {
    [parameters setObject:scope forKey:kOAuthv2Scope];
  }
  if (state) {
    [parameters setObject:state forKey:kOAuthv2State];
  }
  
  return [self URLStringByAddingParameters:parameters];
}

/*
 for "http://www.douban.com/group/12345" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com/group/12345?key=value" will get Range(34, 9) and "key=value"
 for "http://www.douban.com/group/12345/" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com/group/12345/?key=value" will get Range(35, 9) and "key=value"
 for "http://www.douban.com:/group/12345/?key=value" will get Range(36, 9) and "key=value"
 for "http://www.douban.com:/" will get Range(NSNotFound, 0) and nil
 for "http://www.douban.com:/group/12345/?key=value:invalid/form/?bad" will get Range(36, 27) and "key=value:invalid/form/?bad"
 */
- (NSRange)queryRange
{
  NSRange range;
  range = [self rangeOfString:@"?"
                      options:0
                        range:NSMakeRange(0, self.length)];
  if (NSNotFound != range.location) {
    if (range.location + range.length < self.length) {
      NSRange searchRange;
      searchRange.location = range.location + 1;
      searchRange.length = self.length - searchRange.location;
      range = [self rangeOfString:@"#" options:0 range:searchRange];
      if (NSNotFound == range.location) {
        return searchRange;
      } else if (range.location > searchRange.location) {
        NSRange queryRange;
        queryRange.location = searchRange.location;
        queryRange.length = range.location - searchRange.location;
        return queryRange;
      }
    }
  }
  return NSMakeRange(NSNotFound, 0);
}

- (NSString *)query
{
  NSString *query = nil;
  NSRange range = [self queryRange];
  if (NSNotFound != range.location) {
    query = [self substringWithRange:range];
  }
  return query;
}

- (NSDictionary *)queryParameters
{
  NSString *query = [self query];
  return [query decodedUrlencodedParameters];
}

- (NSString *)escapedString
{
  NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(ESCAPE_CHARACTERS), kCFStringEncodingUTF8));
  return newString ? newString : @"";
}

- (NSString *)unescapeString
{
  NSString *newString = CFBridgingRelease((CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8)));
  return newString ? newString : @"";
}

- (NSString *)escapedStringWithoutWhitespace
{
  NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, CFSTR(" "), CFSTR(ESCAPE_CHARACTERS), kCFStringEncodingUTF8));
  return newString ? newString : @"";
}

- (NSString *)urlencodedString
{
#ifdef ESCAPE_WHITESPACE
  return [self escapedString];
#else
  NSString *newString = [self escapedStringWithoutWhitespace];
  newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  return newString;
#endif
}

- (NSString *)urldecodedString
{
  NSString *newString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
  return [newString unescapeString];
}

- (NSDictionary *)decodedUrlencodedParameters
{
  NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
  NSArray *parameters = [self componentsSeparatedByString:@"&"];
  for (NSString *parameter in parameters) {
    NSArray *keyvalue = [parameter componentsSeparatedByString:@"="];
    NSString *key = [keyvalue objectAtIndex:0];
    NSString *value = ([keyvalue count] > 1) ? [keyvalue objectAtIndex:1] : @"";
    NSString *decodedKey = [key urldecodedString];
    NSString *decodedValue = [value urldecodedString];
    
    [responseDictionary addDuplicatableObject:decodedValue forKey:decodedKey];
  }
  return responseDictionary;
}

/*
 for "   " will get Range(NSNotFound, 0) and nil.
 for "http://     /" will get Range(7, 5);
 URL validation should be perfomed by programmer
 */
- (NSRange)hostRange
{
  NSRange range;
  NSRange searchRng;
  
  searchRng.location = 0;
  searchRng.length = [self length];
  
  range = [self rangeOfString:@"://" options:0 range:searchRng];
  
  // if found ://, start new search just behind
  if (NSNotFound != range.location) {
    searchRng.location = range.location + range.length;
    searchRng.length = [self length] - searchRng.location;
  }
  // http://www.douban.com/, or http://www.douban.com:80/, or http://www.douban.com?key=value, or http://www.douban.com
  range = [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":/?#"] options:0 range:searchRng];
  
  //extract host from URL
  if (NSNotFound != range.location) {
    searchRng.length = range.location - searchRng.location;
  }
  return searchRng;
  // this may return "   " for "http://     /"
  // this will not alter the length, so latter function can use this range as a anchor reference
}

- (NSString *)host
{
  NSString *host = nil;
  NSRange rng = [self hostRange];
  if (NSNotFound != rng.location) {
    host = [self substringWithRange:rng];
  }
  return host;
}

@end
