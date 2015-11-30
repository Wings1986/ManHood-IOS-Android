//
//  NSString+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 21.01.10.
//  Copyright 2010. All rights reserved.
//

#import "NSString+Common.h"


@implementation NSString (Common)

+ (id)stringWithUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *uString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return uString;
}

- (NSString *)stringWithBundlePath{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:self];
}

+ (id)pathToBundleFile:(NSString *)aFileName{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:aFileName];
}

+ (id)stringFromBundleFile:(NSString *)aFileName{
	return [NSString stringWithContentsOfFile:[NSString pathToBundleFile:aFileName] encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)isNotEmpty {
	return [self length] > 0;
}

- (NSString*) encodeToSafeURLString {
   return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                (__bridge CFStringRef)self,
                                                                                NULL,
                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8 );	
}

- (BOOL) isValidEmail {

	// E-mail regex complete verification of RFC 2822. :-)
	static NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	// Always return YES, just check if the e-mailaddress is valid yet
	// so we can enable the Send button.
	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (BOOL)isVaildName {
    NSMutableString *testStr = [self mutableCopy];
    [testStr replaceOccurrencesOfString:@" " 
                             withString:@"" 
                                options:0
                                  range:NSMakeRange(0, [self length])];
    return [testStr length] > 0;
}

- (NSComparisonResult) compareNumbers:(NSString*) right {
    
	static NSCharacterSet *charSet = nil;
    if ( charSet == nil ) {
        charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet];
    }
	
	return [[self stringByTrimmingCharactersInSet:charSet] 
            compare:[right stringByTrimmingCharactersInSet:charSet] 
			options:NSCaseInsensitiveSearch | NSNumericSearch];
}

- (NSInteger)countOfCharacter:(char)character {
    const char *characters = [self UTF8String];
    NSUInteger count = 0;
    for (int i = 0 ; i < [self length] ; i++) {
        if ( characters[i] == character ) {
            count++;
        }
    }
    return count;
}

- (NSString*)firstLetter {
    return ([self length] >= 1) ? [[self substringToIndex:1] uppercaseString] : nil;
}

- (NSString*)truncateWithLength:(NSUInteger)length {
   
    // define the range you're interested in
    NSRange stringRange = {0, MIN([self length], length)};
    
    // adjust the range to include dependent chars
    stringRange = [self rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    return [self substringWithRange:stringRange];
}

@end
