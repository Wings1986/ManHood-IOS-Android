//
//  NSDictionary+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 26.10.10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Common)

- (BOOL) valueForKeyIsString:(NSString *)key;
- (BOOL) valueForKeyIsNumber:(NSString *)key;
- (BOOL) valueForKeyIsDictionary:(NSString *)key;
- (BOOL) valueForKeyIsArray:(NSString *)key;
- (BOOL) valueForKeyIsDate:(NSString *)key;
- (BOOL) valueForKeyIsData:(NSString *)key;

- (id) safeValueForKey:(NSString*) key;
- (id) valueForPath: (NSString*) path;
- (id) objectForKey:(NSString *)key orDefault:(id)aDefault;
- (id) valueForKey:(NSString*) key orDefaultForNSNull:(id)aValueForNSNull;

- (id)safeValueForKeyPath:(NSString *)path;
- (NSArray *)arrayOrNilForKeyPath:(NSString *)path;
- (NSDictionary *)dictionaryOrNilForKeyPath:(NSString *)path;
- (NSString *)stringOrNilForKeyPath:(NSString *)path;
- (NSNumber *)numberOrNilForKeyPath:(NSString *)path;

+ (NSDictionary *) dictionaryWithEntriesFromDictionary:(NSDictionary *)otherDictionary forKeys:(NSArray *)keys;
- (NSString *)componentsForKeys:(NSArray *)keys joinedByString:(NSString *)string;
- (id) firstExistingObjectForKeys:(NSArray *)keys;
@end
