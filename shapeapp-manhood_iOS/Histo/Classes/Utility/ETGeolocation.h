//
//  ETGeolocation.h
//  Histo
//
//  Created by Viktor Gubriienko on 02.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface ETGeolocation : NSObject

@property (nonatomic, readonly) CLLocationManager *manager;
@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, copy) void(^locationReceivedBlock)(CLLocation *location);
@property (nonatomic, copy) void(^errorReceivedBlock)(NSError *error);

+ (instancetype)sharedInstance;

- (void)forceUpdate;
- (void)startUpdating;
- (void)stopUpdating;

@end
