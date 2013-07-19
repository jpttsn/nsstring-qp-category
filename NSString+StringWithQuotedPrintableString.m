//
//  NSString+StringWithQuotedPrintableString.m
//  SimpleMessage
//
//  Created by Joel Pettersson on 2013-07-19.
//  Copyright (c) 2013 jopt. All rights reserved.
//

#import "NSString+StringWithQuotedPrintableString.h"

@implementation NSString (StringWithQuotedPrintableString)


/* Convenience functions */

char base16 (unichar n) {
	if (n <= '9') return n - '0';
	else if (n <= 'F') return n - 'A' + 10;
	else return 0;
}

int jointByte(int n1, int n2) {
	return (n1 << 4) | n2;
}

+ (NSString *)stringWithQuotedPrintableString: (NSString *)quotedPrintableString variableLength: (BOOL)variableLength {
	
	NSMutableString *r = [[NSMutableString alloc] init];
	
	for(NSUInteger i = 0; i < [quotedPrintableString length]; i++) {
		
		char c = [quotedPrintableString characterAtIndex:i];
		
		if (c != '=') { /* not escaped */ [r appendFormat:@"%c", c]; } else {
			
			char n1 = [quotedPrintableString characterAtIndex:i+1];
			char n2 = [quotedPrintableString characterAtIndex:i+2];
			
			if (n1 == 13 && n2 == 10) { /* crlf, do nothing */ } else {
				
				n1 = base16(n1);
				n2 = base16(n2);
				int b1 = jointByte(n1, n2);
				
				if (!variableLength) {
					
					unichar u = b1;
					
					[r appendFormat:@"%C", u];
					
				} else {
					
					int numberOfBytes = 1;
					if ((b1 & 224) == 192) numberOfBytes = 2;
					if ((b1 & 240) == 224) numberOfBytes = 3;
					if ((b1 & 255) == 240) numberOfBytes = 4;
					
					if (numberOfBytes > 1) {
						
						char n3 = [quotedPrintableString characterAtIndex:i+4];
						char n4 = [quotedPrintableString characterAtIndex:i+5];
						int b2 = jointByte(base16(n3), base16(n4));
						
						if (numberOfBytes > 2) {
							
							char n5 = [quotedPrintableString characterAtIndex:i+7];
							char n6 = [quotedPrintableString characterAtIndex:i+8];
							int b3 = jointByte(base16(n5), base16(n6));
							
							if (numberOfBytes > 3 ) { /* 4 bytes */
								
								char n7 = [quotedPrintableString characterAtIndex:i+10];
								char n8 = [quotedPrintableString characterAtIndex:i+11];
								int b4 = jointByte(base16(n7), base16(n8));
								
								UInt32 *lu = malloc(sizeof(UInt32));
								*lu = ((b1 & 7) << 18) | ((b2 & 63) << 12) | ((b3 & 63) << 6) | (b4 & 63);
								NSData *d = [NSData dataWithBytes:lu length:sizeof(UInt32)];
								NSString* s = [[NSString alloc] initWithData:d encoding:NSUTF32LittleEndianStringEncoding];
								free(lu);
								
								[r appendFormat:@"%@", s];
								i += 9;
								
							} else { /* 3 bytes */
								
								unichar u = ((b1 & 15) << 12) | ((b2 & 63) << 6) | (b3 & 63);
								
								[r appendFormat:@"%C", u];
								i += 6;
							}
							
						} else { /* 2 bytes */
							
							unichar u = ((b1 & 31) << 6) | (b2 & 63);
							
							[r appendFormat:@"%C", u];
							i += 3;
						}
					}
				}
			}
			
			i += 2;
		}
	}
	
	return [NSString stringWithString:r];
}

@end
