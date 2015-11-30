//
//  NSObject+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 5/20/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (Common)

- (void) printClassHieararhy;

- (void)logProperties;
- (void)logPropertiesSubLevels:(NSInteger)aSubLevels;

- (BOOL) isNumber;
- (BOOL) isString;
- (BOOL) isDictionary;
- (BOOL) isArray;
- (BOOL) isDate;
- (BOOL) isData;

+ (NSString *)className;
- (NSString *)className;

- (void)setAssosiatedValue:(id)value forKey:(NSString*)key;
- (id)assosiatedValueForKey:(NSString*)key;

@end
