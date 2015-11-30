//
//  SelfUserData.m
//  CoolHisto
//
//  Created by Viktor Gubriienko on 26.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import "SelfUserData.h"

static NSInteger const kJSONUserLengthIndex         = 0;
static NSInteger const kJSONUserGirthIndex          = 1;
static NSInteger const kJSONUserThicknessIndex      = 2;
static NSInteger const kJSONUserCirclesIndex        = 3;
static NSInteger const kJSONUserDateIndex           = 4;
static NSInteger const kJSONUserDeviceIndex         = 5;

static NSInteger const kJSONUserCircleBaseIndex     = 0;
static NSInteger const kJSONUserCircleMidIndex      = 1;
static NSInteger const kJSONUserCircleUpperIndex    = 2;
static NSInteger const kJSONUserCircleTipIndex      = 3;

static NSInteger const kJSONUserCircleXIndex        = 0;
static NSInteger const kJSONUserCircleYIndex        = 1;

@implementation SelfUserData {
    NSArray *_user;
}

- (instancetype)initWithContentsOfFile:(NSString*)filePath {
    self = [super init];
    if (self) {
        _user = [NSArray arrayWithContentsOfFile:filePath];
        if ( _user == nil ) {
            return self = nil;
        }
    }
    return self;
    
}
- (instancetype)initWithContentsOfFile1:(NSString*)filePath {
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        _user = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"YOU"];

        if ( _user == nil ) {
            return self = nil;
        }
    }
    return self;
    
}

#pragma mark - DynamicProperties

- (float)length {
    return [_user[kJSONUserLengthIndex] floatValue];
}

- (float)girth {
    return [_user[kJSONUserGirthIndex] floatValue];
}

- (float)thickness {
    return [_user[kJSONUserThicknessIndex] floatValue];
}

- (CGPoint)basePosition {
    return CGPointMake([_user[kJSONUserCirclesIndex][kJSONUserCircleBaseIndex][kJSONUserCircleXIndex] floatValue],
                       [_user[kJSONUserCirclesIndex][kJSONUserCircleBaseIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)midPosition {
    return CGPointMake([_user[kJSONUserCirclesIndex][kJSONUserCircleMidIndex][kJSONUserCircleXIndex] floatValue],
                       [_user[kJSONUserCirclesIndex][kJSONUserCircleMidIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)upperPosition {
    return CGPointMake([_user[kJSONUserCirclesIndex][kJSONUserCircleUpperIndex][kJSONUserCircleXIndex] floatValue],
                       [_user[kJSONUserCirclesIndex][kJSONUserCircleUpperIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)tipPosition {
    return CGPointMake([_user[kJSONUserCirclesIndex][kJSONUserCircleTipIndex][kJSONUserCircleXIndex] floatValue],
                       [_user[kJSONUserCirclesIndex][kJSONUserCircleTipIndex][kJSONUserCircleYIndex] floatValue]);
}

- (NSString *)device {
    return _user[kJSONUserDeviceIndex];
}

- (NSDate *)date {
    static NSDateFormatter *dateFormatter;
    if ( dateFormatter == nil ) {
        //'01.01.2014 00:00'
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    }
    
    return [dateFormatter dateFromString:_user[kJSONUserDateIndex]];
}

@end
