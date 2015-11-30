//
//  ETGeolocation.m
//  Histo
//
//  Created by Viktor Gubriienko on 02.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETGeolocation.h"

@interface ETGeolocation ()

<
CLLocationManagerDelegate
>

@end


@implementation ETGeolocation {
    BOOL _updatingManually;
    __weak UIAlertView *_currentAlert;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedInstance = [self new]; });
    
    return sharedInstance;
}

#pragma mark - Public

- (void)forceUpdate {
    [self startUpdating];
}

- (void)startUpdating {
    
    [self stopUpdating];
    
    if ( [CLLocationManager significantLocationChangeMonitoringAvailable] ) {
        [_manager startMonitoringSignificantLocationChanges];
        _updatingManually = NO;
    } else {
        [_manager startUpdatingLocation];
        _updatingManually = YES;
    }
}

- (void)stopUpdating {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdating) object:nil];
    [_manager stopMonitoringSignificantLocationChanges];
    [_manager stopUpdatingLocation];
}

#pragma mark - Location delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_manager stopUpdatingLocation];
    
    _currentLocation = locations.lastObject;
    
    if ( _locationReceivedBlock ) {
        _locationReceivedBlock([locations lastObject]);
    }
    
    if ( _updatingManually ) {
        [self performSelector:@selector(startUpdating) withObject:nil afterDelay:300.0];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if ( _errorReceivedBlock ) {
        _errorReceivedBlock(error);
    }

    if ( error.code == kCLErrorDenied ) {
        [self stopUpdating];
        
        if (_currentAlert == nil) {
            _currentAlert = [UIAlertView showWithTitle:@"Turn On Location Services to Allow \"ManHood\" to Determine Your Location"
                                               message:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil
                                              tapBlock:nil];
        }
    }
}

#pragma mark - DynamicProperties 

- (BOOL)enabled {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized && [CLLocationManager locationServicesEnabled];
}

#pragma mark - Dealloc

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdating) object:nil];
}

@end
