//
//  NSDictionary+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 26.10.10.
//  Copyright 2010. All rights reserved.
//

#import "NSDictionary+Common.h"
#import "NSObject+Common.h"

@implementation NSDictionary (Common)

- (BOOL) valueForKeyIsString:(NSString *)key {
	return [[self valueForKey:key] isString];
}

- (BOOL) valueForKeyIsNumber:(NSString *)key {
	return [[self valueForKey:key] isNumber];	
}

- (BOOL) valueForKeyIsDictionary:(NSString *)key {
	return [[self valueForKey:key] isDictionary];	
}

- (BOOL) valueForKeyIsArray:(NSString *)key {
	return [[self valueForKey:key] isArray];
}

- (BOOL) valueForKeyIsDate:(NSString *)key {
	return [[self valueForKey:key] isData];
}

- (BOOL) valueForKeyIsData:(NSString *)key {
	return [[self valueForKey:key] isDate];
}

- (id) safeValueForKey:(NSString*) key {
    id value = [self valueForKey:key];
    return (value == [NSNull null]) ? nil : value ;
}

- (id) valueForKey:(NSString*) key orDefaultForNSNull:(id)aValueForNSNull{
    id value = [self valueForKey:key];
    return (value == [NSNull null]) ? aValueForNSNull : value ;
}

- (id) valueForPath: (NSString*) path
{
  NSArray* components = [path componentsSeparatedByString: @"."];
  
  id object = self;
  
  for (NSString* key in components)
  {
    object = [object objectForKey: key];
    
    if ([object isKindOfClass: [NSArray class]] && ([object count] == 1))
      object = [object objectAtIndex: 0];
  }
  
  return object;
}


- (id) objectForKey:(NSString *)key orDefault:(id)aDefault{
	id result = [self objectForKey:key];
    return (result) ? result : aDefault;
}

- (id)safeValueForKeyPath:(NSString *)path{
    NSArray * pathComponents = [path componentsSeparatedByString:@"."];
    id res = self;
    SEL sel = @selector(valueForKey:);
    for(NSString * component in  pathComponents){
        if ([res respondsToSelector:sel]){
            res = [res valueForKey:component];
        }
        else{
            res = nil;
            break;
        }
    }
    return res;
}


- (NSArray *)arrayOrNilForKeyPath:(NSString *)path{
    NSArray * res = [self safeValueForKeyPath:path];
    if ([res isKindOfClass:[NSArray class]]){
        return res;
    }
    return nil;
}

- (NSDictionary *)dictionaryOrNilForKeyPath:(NSString *)path{
    NSDictionary * res = [self safeValueForKeyPath:path];
    if ([res isKindOfClass:[NSDictionary class]]){
        return res;
    }
    return nil;
}

- (NSString *)stringOrNilForKeyPath:(NSString *)path{
    NSString * res = [self safeValueForKeyPath:path];
    if ([res isKindOfClass:[NSString class]]){
        return res;
    }
    return nil;
}

- (NSNumber *)numberOrNilForKeyPath:(NSString *)path{
    NSNumber * res = [self safeValueForKeyPath:path];
    if ([res isKindOfClass:[NSNumber class]]){
        return res;
    }
    return nil;
}

+ (NSDictionary *) dictionaryWithEntriesFromDictionary:(NSDictionary *)otherDictionary forKeys:(NSArray *)keys{
    return [NSDictionary dictionaryWithDictionary:[NSMutableDictionary dictionaryWithEntriesFromDictionary:otherDictionary forKeys:keys]];
}

- (NSString *)componentsForKeys:(NSArray *)keys joinedByString:(NSString *)string{
    NSString * delimeter = @"";
    NSMutableString * resStr = [[NSMutableString alloc] init];
    for (id key  in keys) {
        id obj = [self objectForKey:key];
        if (obj){
            [resStr appendFormat:@"%@%@", delimeter, obj];
            delimeter = string;
        }
    }
    return [NSString stringWithString:resStr];
}

- (id) firstExistingObjectForKeys:(NSArray *)keys{
    for (id key  in keys) {
        id obj = [self objectForKey:key];
        if (obj){
            return obj;
        }
    }
    return nil;
}

@end
