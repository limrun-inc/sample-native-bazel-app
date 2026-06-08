#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Small Objective-C string helper, exercised from Swift to keep the sample
/// mixed-language.
@interface StringUtils : NSObject

/// Returns the input string reversed.
+ (NSString *)reverse:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
