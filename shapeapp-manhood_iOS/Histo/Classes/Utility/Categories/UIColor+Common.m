//
//  UIColor+Common.m
//  Common
//
//  Created by Vlad Dudkin on 6/20/11.
//  Copyright 2011 VLFN. All rights reserved.
//

#import "UIColor+Common.h"


@implementation UIColor (Common)

+ (UIColor *) colorWithHexValue:(NSUInteger)aHexValue{
    return [UIColor colorWithHexValue:aHexValue alpha:1.0];
}


+ (UIColor *) colorWithHexValue:(NSUInteger)aHexValue alpha:(CGFloat)anAlpha{
	NSUInteger b = aHexValue % 0x100;
	NSUInteger g = (aHexValue / 0x100) % 0x100;
	NSUInteger r = (aHexValue / 0x10000);
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:anAlpha];
}

@end
