#import <Foundation/Foundation.h>

@interface NSString (StringWithQuotedPrintableString)

+ (NSString *)stringWithQuotedPrintableString: (NSString *)quotedPrintableString variableLength: (BOOL)variableLength;

@end
