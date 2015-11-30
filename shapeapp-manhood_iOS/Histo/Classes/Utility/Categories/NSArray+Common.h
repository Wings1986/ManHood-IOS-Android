//
//  NSArray+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 5/17/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Common_1) 

- (BOOL) isValidIndex:(NSInteger) index;
- (NSArray*) filteredArrayUsingPredicateFormat:(NSString*) predicateFormat, ...;
- (id)objectAtIndex:(NSUInteger)index orDefaultObject:(id) defObj;
- (id)objectWithKey:(NSString*) key equalTo:(id) value;
- (id) firstObject;

@end
