//
//  ETUnitConverter.h
//  Histo
//
//  Created by Viktor Gubriienko on 07.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ConverterUnitTypeCM,
    ConverterUnitTypeINCH
} ConverterUnitType;


@interface ETUnitConverter : NSObject

+ (float)convertCMValue:(float)value toUnit:(ConverterUnitType)unitType;
+ (NSString*)nameForUnitType:(ConverterUnitType)unitType;

+ (ConverterUnitType)typeFromString:(NSString*)string;

@end
