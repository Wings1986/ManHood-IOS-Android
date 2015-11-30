//
//  UIColor+Common.h
//
//  Created by Vlad Dudkin on 6/20/11.
//  Copyright 2011 VLFN. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (Common)

+ (UIColor *) colorWithHexValue:(NSUInteger)aHexValue;
+ (UIColor *) colorWithHexValue:(NSUInteger)aHexValue alpha:(CGFloat)anAlpha;


@end
