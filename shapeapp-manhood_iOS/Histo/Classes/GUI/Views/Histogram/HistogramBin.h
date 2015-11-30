//
//  HistogramBin.h
//  CoolHisto
//
//  Created by Viktor Gubriienko on 18.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistogramBin : NSObject

@property (nonatomic, readonly) float leftEdge;
@property (nonatomic, readonly) float rightEdge;
@property (nonatomic, readonly) float binCount;

- (instancetype)initWithLeftEdge:(float)leftEdge rightEdge:(float)rightEdge binCount:(float)binCount;
+ (instancetype)histogramBinWithLeftEdge:(float)leftEdge rightEdge:(float)rightEdge binCount:(float)binCount;

@end
