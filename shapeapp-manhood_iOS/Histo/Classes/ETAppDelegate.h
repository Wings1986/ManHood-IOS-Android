//
//  ETAppDelegate.h
//  Histo
//
//  Created by Idriss on 16/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETGeolocation;
@class ETFlow;
@interface ETAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (ETAppDelegate*)instance;

- (ETFlow*)createCameraFlow;

- (void)purchaseOneMonthSubscription;
- (void)restorePurchases;

@end
