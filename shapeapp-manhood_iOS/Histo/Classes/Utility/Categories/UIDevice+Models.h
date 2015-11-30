//
//  UIDevice+Models.h
//  Histo
//
//  Created by Viktor Gubriienko on 21.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Models)

+ (NSString*)hardwareModel;

+ (BOOL)isSimulator;
+ (BOOL)isiPad;
+ (BOOL)isiPhone;
+ (BOOL)isiPod;
+ (BOOL)isiPhoneOriPod;

@end
