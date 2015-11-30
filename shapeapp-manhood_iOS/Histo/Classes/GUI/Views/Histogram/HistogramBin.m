//
//  HistogramBin.m
//  CoolHisto
//
//  Created by Viktor Gubriienko on 18.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import "HistogramBin.h"

@implementation HistogramBin

- (instancetype)initWithLeftEdge:(float)leftEdge rightEdge:(float)rightEdge binCount:(float)binCount {
    self = [super init];
    if (self) {
        _leftEdge = leftEdge;
        _rightEdge = rightEdge;
        _binCount = binCount;
    }
    return self;
}

+ (instancetype)histogramBinWithLeftEdge:(float)leftEdge rightEdge:(float)rightEdge binCount:(float)binCount {
    return [[self alloc] initWithLeftEdge:leftEdge rightEdge:rightEdge binCount:binCount];
}

@end
