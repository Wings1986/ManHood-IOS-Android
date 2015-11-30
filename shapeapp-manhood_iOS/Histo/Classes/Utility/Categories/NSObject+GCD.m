//
//  NSObject+GCD.m
//  FitnessPrototype
//
//  Created by Viktor Gubriienko on 22.03.13.
//  Copyright (c) 2013 Allan Ray Jasa. All rights reserved.
//

#import "NSObject+GCD.h"

@implementation NSObject (GCD)

+ (void)dispatchAfter:(NSTimeInterval)sec block:(void(^)())block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
