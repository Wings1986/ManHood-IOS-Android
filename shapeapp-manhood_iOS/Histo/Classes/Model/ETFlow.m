//
//  ETFlow.m
//  Histo
//
//  Created by Viktor Gubriienko on 12.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETFlow.h"

@implementation ETFlow

- (ETFlowStep*)stepWithID:(NSString*)ID {
    for (ETFlowStep *step in _steps) {
        if ( [step.ID isEqualToString:ID] ) {
            return step;
        }
    }
    
    return nil;
}

- (ETFlowStep*)moveToNextStep {
    NSUInteger currentIndex = [self.steps indexOfObject:self.currentStep];
    if ( currentIndex == NSNotFound ) {
        _currentStep = [self.steps firstObject];
    } else {
        currentIndex++;
        if ( currentIndex >= self.steps.count ) {
            _currentStep = nil;
        } else {
            _currentStep = self.steps[currentIndex];
        }
    }

    return _currentStep;
}

- (ETFlowStep*)moveToPreviousStep {
    NSUInteger currentIndex = [self.steps indexOfObject:self.currentStep];
    if ( currentIndex == NSNotFound ) {
        _currentStep = nil;
    } else {
        if ( currentIndex != 0 ) {
            [self.currentStep reset];
            currentIndex--;
            _currentStep = self.steps[currentIndex];
        } else {
            _currentStep = nil;
        }
    }
    
    return _currentStep;
}

- (void)reset {
    
    for (ETFlowStep *step in self.steps) {
        [step reset];
        step.data = nil;
    }
    
    _currentStep = nil;
}

#pragma mark - DynamicProperties

- (void)setSteps:(NSArray *)steps {
    _steps = steps;
    
    _currentStep = nil;
}
@end
