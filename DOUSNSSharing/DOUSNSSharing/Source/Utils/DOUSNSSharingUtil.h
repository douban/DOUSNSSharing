//
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_INSTANCE_OF(_x, _class) ([_x isKindOfClass:[_class class]])


#ifdef DEBUG
#define DOUSNSSharingErrorLog(s, ...) NSLog(@"DOUSNSSharing Error %s(%d): %@", \
__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define DOUSNSSharingWarnLog(s, ...) NSLog(@"DOUSNSSharing Warn %s(%d): %@", \
__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define DOUSNSSharingInfoLog(s, ...) NSLog(@"DOUSNSSharing Info %s(%d): %@", \
__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define DOUSNSSharingDebugLog(s, ...) NSLog(@"DOUSNSSharing Debug %s(%d): %@", \
__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#else

#define DOUSNSSharingErrorLog(s, ...) ((void)0)
#define DOUSNSSharingWarnLog(s, ...) ((void)0)
#define DOUSNSSharingInfoLog(s, ...) ((void)0)
#define DOUSNSSharingDebugLog(s, ...) ((void)0)

#endif


@interface DOUSNSSharingUtil : NSObject

+ (id)objectFromJSONString:(NSString *)jsonString;

@end
