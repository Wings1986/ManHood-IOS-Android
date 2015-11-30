//
//  ETFlow.h
//  Histo
//
//  Created by Viktor Gubriienko on 12.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETFlowStep.h"

@interface ETFlow : NSObject

@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, readonly) ETFlowStep *currentStep;

- (ETFlowStep*)stepWithID:(NSString*)ID;

- (ETFlowStep*)moveToNextStep;
- (ETFlowStep*)moveToPreviousStep;

- (void)reset;

@end
