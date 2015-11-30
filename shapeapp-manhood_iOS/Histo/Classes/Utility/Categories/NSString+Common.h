//
//  NSString+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 21.01.10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Common)

+ (id)stringWithUUID;
- (NSString *)stringWithBundlePath;
+ (id)pathToBundleFile:(NSString *)aFileName;
+ (id)stringFromBundleFile:(NSString *)aFileName;
- (BOOL)isNotEmpty;
- (NSString*)encodeToSafeURLString;
- (NSInteger)countOfCharacter:(char)character;

- (BOOL) isValidEmail;
- (BOOL)isVaildName;

- (NSComparisonResult) compareNumbers:(NSString*) right;

- (NSString*)firstLetter;

- (NSString*)truncateWithLength:(NSUInteger)length;

@end
