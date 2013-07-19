* Soft line breaks (as in '=' then CRLF) are removed
* Escaped character codes (as in '=' then hex values) are replaced with the real characters

Set `variableLength` to handle UTF-8 characters expressed in more than one escape.

This illustrates how it works:

	NSLog(@"ö = %@", [NSString stringWithQuotedPrintableString:@"=C3=B6" variableLength:YES]);
	NSLog(@" = %@", [NSString stringWithQuotedPrintableString:@"=EF=A3=BF" variableLength:YES]);
	NSLog(@"𠜎 = %@", [NSString stringWithQuotedPrintableString:@"=F0=A0=9C=8E" variableLength:YES]);
	