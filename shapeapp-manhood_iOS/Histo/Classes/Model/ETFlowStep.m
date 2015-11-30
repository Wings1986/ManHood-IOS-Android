//
//  ETFlowStep.m
//  Histo
//
//  Created by Viktor Gubriienko on 12.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETFlowStep.h"

@implementation ETFlowStep

- (void)reset {
    if ( _finilizeBlock ) {
        _finilizeBlock(self);
    }
}

- (void)dealloc {
    [self reset];
}

@end
