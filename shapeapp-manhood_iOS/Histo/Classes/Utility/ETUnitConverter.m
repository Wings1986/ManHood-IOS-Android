//
//  ETUnitConverter.m
//  Histo
//
//  Created by Viktor Gubriienko on 07.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETUnitConverter.h"
#import "NSUserDefaults+Preferences.h"

@implementation ETUnitConverter

+ (float)convertCMValue:(float)value toUnit:(ConverterUnitType)unitType {
    switch (unitType) {
        case ConverterUnitTypeCM: return value;
        case ConverterUnitTypeINCH: return value / 2.54f;
        default: return value;
    }
}

+ (NSString*)nameForUnitType:(ConverterUnitType)unitType {
    switch (unitType) {
        case ConverterUnitTypeCM: return @"CM";
        case ConverterUnitTypeINCH: return @"IN";
        default: return @"";
    }
}

+ (ConverterUnitType)typeFromString:(NSString*)string {
    if ([string isEqualToString:unitImperial]) {
        return ConverterUnitTypeINCH;
    } else if ([string isEqualToString:unitMetric]) {
        return ConverterUnitTypeCM;
    } else {
        return ConverterUnitTypeCM;
    }
}

@end
