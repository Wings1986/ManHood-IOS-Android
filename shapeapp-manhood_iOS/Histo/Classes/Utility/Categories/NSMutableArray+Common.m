//
//  NSMutableArray+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import "NSMutableArray+Common.h"


@implementation NSMutableArray (Common)

- (void) addObjectOrNSNull:(id) anObject {
	[self addObject:( anObject == nil ) ? [NSNull null] : anObject ];
}

- (void) addObjectOrNothing:(id) anObject {
	if ( anObject ) {
		[self addObject:anObject];
	}
}

- (void) reverse {
	NSUInteger count = [self count];
	NSUInteger halfCount = count / 2;
	for (int i = 0; i < halfCount; i++) {
		[self exchangeObjectAtIndex:i withObjectAtIndex:count - i - 1];
	}
}

- (void)moveObjectAtIndex:(NSUInteger)indexFrom toIndex:(NSUInteger)indexTo {
    id obj = [self objectAtIndex:indexFrom];
    [self removeObjectAtIndex:indexFrom];
    [self insertObject:obj atIndex:indexTo];
}

@end
