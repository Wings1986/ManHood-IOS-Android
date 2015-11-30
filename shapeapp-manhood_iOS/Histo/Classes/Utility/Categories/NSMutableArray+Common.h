//
//  NSMutableArray+Common.h
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (Common)

- (void) addObjectOrNSNull:(id) anObject;
- (void) addObjectOrNothing:(id) anObject;
- (void) reverse;
- (void)moveObjectAtIndex:(NSUInteger)indexFrom toIndex:(NSUInteger)indexTo;

@end
