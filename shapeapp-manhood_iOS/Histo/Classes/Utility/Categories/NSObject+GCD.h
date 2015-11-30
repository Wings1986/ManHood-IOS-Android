//
//  NSObject+GCD.h
//  FitnessPrototype
//
//  Created by Viktor Gubriienko on 22.03.13.
//  Copyright (c) 2013 Allan Ray Jasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GCD)

+ (void)dispatchAfter:(NSTimeInterval)sec block:(void(^)())block;

@end
