#import "StringUtils.h"

@implementation StringUtils

+ (NSString *)reverse:(NSString *)input {
    NSMutableString *reversed = [NSMutableString stringWithCapacity:input.length];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length)
                              options:NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences
                           usingBlock:^(NSString *_Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                               [reversed appendString:substring];
                           }];
    return reversed;
}

@end
