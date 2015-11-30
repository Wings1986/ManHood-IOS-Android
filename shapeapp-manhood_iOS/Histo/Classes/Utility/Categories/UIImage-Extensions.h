//
//  UIImage-Extensions.h
//
//  Created by Hardy Macia on 7/1/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
#import <Foundation/Foundation.h>

CGFloat RadiansToDegrees(CGFloat radians);
CGFloat DegreesToRadians(CGFloat degrees);

@interface UIImage (CS_Extensions)

- (UIImage*) imageAtRect:(CGRect)rect;
- (UIImage*) imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage*) imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize contentSize:(CGSize*)content;
- (UIImage*) imageByScalingToSize:(CGSize)targetSize;
- (UIImage*) imageRotatedByRadians:(CGFloat)radians;
- (UIImage*) imageRotatedByDegrees:(CGFloat)degrees;
+ (UIImage*) fastImageWithContentsOfFile:(NSString*)path;
- (CGSize)   sizeByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*) rotate:(UIImageOrientation)orient;
- (UIImage*) rotateToPortrait;
- (CGRect)   scaleSizeWithProportion:(CGSize)allow;
- (CGRect)   scaleSizeWithProportion1:(CGSize)allow;
- (UIImage*) imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end;