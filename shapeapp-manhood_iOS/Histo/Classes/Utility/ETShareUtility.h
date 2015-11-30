//
//  ETShareUtility.h
//  Histo
//
//  Created by Viktor Gubriienko on 01.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETShareUtility : NSObject

+ (void)shareHistogramSnapshot:(UIImage*)snapshot onViewController:(UIViewController*)ctrl;
+ (void)shareTheAppViaEmailOnViewController:(UIViewController*)ctrl;
+ (void)tellAFriendViaEmailOnViewController:(UIViewController*)ctrl;
+ (void)shareTheAppViaMessageOnViewController:(UIViewController*)ctrl;
+ (void)shareTheAppViaTwitterOnViewController:(UIViewController*)ctrl;
+ (void)shareTheAppViaFacebookOnViewController:(UIViewController*)ctrl;

@end
