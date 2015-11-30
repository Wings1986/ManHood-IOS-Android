//
//  Histogram.m
//  CoolHisto
//
//  Created by Viktor Gubriienko on 18.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Histogram.h"
#import "HistogramRecognizer.h"

typedef enum {
    HistogramAnimationNA,
    HistogramAnimationCreate,
    HistogramAnimationUpdate,
    HistogramAnimationSelection,
} HistogramAnimation;


@implementation Histogram {
    CALayer *_backLayer;
    CATextLayer *_highlightedBinTextLayer;
    CATextLayer *_secondHighlightedBinTextLayer;
    NSMutableArray *_binLayers;
    HistogramRecognizer *_panRecognizer;
    NSArray *_animationOptions;
    NSDate *_lastUpdateDate;
    HistogramFinishBlock _finishBlock;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialSetup];
}

- (void)initialSetup {
    
    _animated = YES;
    _animationOptions = @[@{@"Duration": @0.0,
                            @"Shift": @0.0},
                          @{@"Duration": @0.5,
                            @"Shift": @0.04},
                          @{@"Duration": @0.3,
                            @"Shift": @0.01},
                          @{@"Duration": @0.1,
                            @"Shift": @0.00},
                          ];
    
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    _binLayers = [NSMutableArray new];
    _binTextTransform = CATransform3DIdentity;
    _panRecognizer = [[HistogramRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    _highlightedBinIndex = NSNotFound;
    _highlightedBinColor = [UIColor colorWithRed:0 green:0.79 blue:0.41 alpha:1];
    _secondHighlightedBinIndex = NSNotFound;
    _secondHighlightedBinColor = [UIColor colorWithRed:0.13 green:0.63 blue:0.86 alpha:1];
    _binColor = [UIColor whiteColor];
    _selectedWidth = 20.0f;
    [self addGestureRecognizer:_panRecognizer];
    [self scaleForBinLayer:nil withTouchPoint:CGPointZero];
    
    _highlightedBinTextLayer = [CATextLayer new];
    _secondHighlightedBinTextLayer = [CATextLayer new];
    [self setupTextLayer:_highlightedBinTextLayer];
    [self setupTextLayer:_secondHighlightedBinTextLayer];

}

- (void)setupTextLayer:(CATextLayer*)textLayer {
    static UIFont *font;
    static CGFloat textHeight = 0;
    if ( font == nil ) {
        font = [UIFont fontWithName:@"Exo-Regular" size:14.0f];
        textHeight = [@"X" sizeWithAttributes:@{NSFontAttributeName:font}].height;
    }
    
    textLayer.frame = CGRectMake(0.0f, 0.0f, 0.0f, textHeight);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.font = (__bridge CFTypeRef)(font.fontName);
    textLayer.fontSize = font.pointSize;
    textLayer.rasterizationScale = 1.0f;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
}

#pragma mark - View

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutBinLayersWithAnimation:HistogramAnimationUpdate finishBlock:nil];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self layoutBinLayersWithAnimation:HistogramAnimationUpdate finishBlock:nil];
}

#pragma mark - Gesture Actions

- (void)panDetected:(HistogramRecognizer*)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            
            [self cancelEndPanAction];
            
            _selecting = YES;
            [self updateLayersWithForTouchPoint:[sender locationInView:self]];
            
        } break;
        case UIGestureRecognizerStateChanged: {
            
            [self updateLayersWithForTouchPoint:[sender locationInView:self]];
            
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            
            [self performSelector:@selector(endPan) withObject:NO afterDelay:1.0];
            
            if ( _valueSelectionChangedBlock ) {
                _valueSelectionChangedBlock(self, HistogramSelectionStateDelayedFinish, 0.0f, nil);
            }
            
        } break;
        default: break;
    }
}

- (void)endPan {
    _selecting = NO;
    
    for (CAShapeLayer *layer in _binLayers) {
        layer.fillColor = [self colorForBinLayer:layer];
        layer.transform = CATransform3DIdentity;
    }
    
    if ( _valueSelectionChangedBlock ) {
        _valueSelectionChangedBlock(self, HistogramSelectionStateNotSelected, 0.0f, nil);
    }
}

- (void)cancelEndPanAction {
    _selecting = NO;
    for (CAShapeLayer *layer in _binLayers) {
        layer.fillColor = [self colorForBinLayer:layer];
        layer.transform = CATransform3DIdentity;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(endPan)
                                               object:nil];
}

#pragma mark - Private

- (void)updateLayersWithForTouchPoint:(CGPoint)point {
    CGPoint touchPoint = [_backLayer convertPoint:point fromLayer:self.layer];
    for (CAShapeLayer *layer in _binLayers) {
        layer.fillColor = [self colorForBinLayer:layer];
        
        CGFloat translationX = [self translationXForBinLayer:layer withTouchPoint:touchPoint];
        CGFloat translationY = [self translationYForBinLayer:layer withTouchPoint:touchPoint];
        CGFloat scale = [self scaleForBinLayer:layer withTouchPoint:touchPoint];
        CATransform3D tr = CATransform3DMakeTranslation(translationX, translationY, 0.0f);
        layer.transform = CATransform3DScale(tr, scale, 1.0f, 1.0f);
    }
    
    CAShapeLayer *layer = [self layerForPoint:point];
    layer.fillColor = [UIColor greenColor].CGColor;

    if ( _valueSelectionChangedBlock ) {
        if ( _lastUpdateDate == nil || -[_lastUpdateDate timeIntervalSinceNow] > 0.1 ) {
            HistogramBin *bin;
            if ( layer ) {
                bin = _bins[[_binLayers indexOfObject:layer]];
            }
            
            _valueSelectionChangedBlock(self, HistogramSelectionStateSelected, [self edgeValueForPoint:touchPoint], bin);
            _lastUpdateDate = [NSDate date];
        }
    }
}

- (CAShapeLayer*)layerForPoint:(CGPoint)point {
    for (CAShapeLayer *layer in _binLayers) {
        CGPoint currentLayerPoint = [layer convertPoint:point fromLayer:self.layer];
        if ( CGPathContainsPoint(layer.path, NULL, currentLayerPoint, true) ) {
            return layer;
        }
    }
    
    return nil;
}

- (void)removeBinLayers {
    [_binLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_binLayers removeAllObjects];
}

- (void)layoutBinLayersWithAnimation:(HistogramAnimation)animation finishBlock:(HistogramFinishBlock)finishBlock {
    
    if ( !_animated ) {
        animation = HistogramAnimationNA;
    }
    
    NSInteger selectedBinsCount = (_highlightedBinIndex != NSNotFound && _highlightedBinIndex != _secondHighlightedBinIndex) + (_secondHighlightedBinIndex != NSNotFound);
    
    CGFloat padding = 0.0f;
    CGRect histoRect = CGRectMake(padding,
                                  padding,
                                  self.bounds.size.width - padding * 2.0f,
                                  self.bounds.size.height - padding * 2.0f);
    
    CGFloat indent = 1.0f;
    
    if ( _backLayer == nil ) {
        _backLayer = [CALayer layer];
        [self.layer addSublayer:_backLayer];
    }
    
    _backLayer.frame = histoRect;

    NSInteger binCount = _bins.count;
    CGFloat binWidth = ((histoRect.size.width - histoRect.origin.x - indent * (binCount - 1) - selectedBinsCount * _selectedWidth) / (binCount - selectedBinsCount));
    
    CGFloat binHeightMultiplier = histoRect.size.height / [self maxBinCount];
    
    [_bins enumerateObjectsUsingBlock:^(HistogramBin *bin, NSUInteger idx, BOOL *stop) {
        
        CAShapeLayer *binLayer;
        
        CGFloat binOriginX = idx * (binWidth + indent);
        
        if ( idx > _highlightedBinIndex && _highlightedBinIndex != _secondHighlightedBinIndex ) {
            binOriginX += _selectedWidth - binWidth;
        }

        if ( idx > _secondHighlightedBinIndex ) {
            binOriginX += _selectedWidth - binWidth;
        }
        
        CGFloat finalBinWidth = (idx == _highlightedBinIndex || idx == _secondHighlightedBinIndex) ? _selectedWidth : binWidth ;
        CGFloat finalBinHeight = (_shouldMaxSelectedBinHeight && (idx == _highlightedBinIndex || idx == _secondHighlightedBinIndex))
                ? histoRect.size.height
                : bin.binCount * binHeightMultiplier ;
        
        if ( _binLayers.count != _bins.count ) {
            binLayer = [CAShapeLayer new];
            binLayer.lineWidth = 1.0f;
            binLayer.rasterizationScale = [UIScreen mainScreen].scale;
            binLayer.contentsScale = [UIScreen mainScreen].scale;
            //binLayer.shouldRasterize = YES;
            [self.layer addSublayer:binLayer];
            [_binLayers addObject:binLayer];
            binLayer.frame = histoRect;
            binLayer.path = [[UIBezierPath bezierPathWithRect:CGRectMake(binOriginX,
                                                                         binLayer.bounds.size.height,
                                                                         finalBinWidth,
                                                                         0.0f)] CGPath];
        } else {
            binLayer = _binLayers[idx];
        }
        
        if ( idx == _secondHighlightedBinIndex ) {
            binLayer.fillColor = _secondHighlightedBinColor.CGColor;
        } else if ( idx == _highlightedBinIndex ) {
            binLayer.fillColor = _highlightedBinColor.CGColor;
        } else {
            binLayer.fillColor = _binColor.CGColor;
        }
        
        CATransform3D currentTransform = binLayer.transform;
        binLayer.transform = CATransform3DIdentity;
        
        binLayer.anchorPoint = CGPointMake(((idx + 0.5) * (binWidth + indent)) / histoRect.size.width , 1.0);
        binLayer.frame = histoRect;
        
        CGRect binPathRect = CGRectMake(binOriginX,
                                        binLayer.bounds.size.height - finalBinHeight,
                                        finalBinWidth,
                                        finalBinHeight);
        
        UIBezierPath *binPath = [UIBezierPath bezierPathWithRect:binPathRect];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        
        CAShapeLayer *temp;
        if ([[binLayer animationKeys] count] > 0) {
            temp = (CAShapeLayer *) [binLayer presentationLayer];
            [anim setFromValue:(__bridge id)temp.path];
        } else {
            [anim setFromValue:(__bridge id)binLayer.path];
        }

        [anim setToValue:(__bridge id)binPath.CGPath];
        [anim setDuration:[_animationOptions[animation][@"Duration"] doubleValue]];
        [anim setBeginTime:CACurrentMediaTime() + idx * [_animationOptions[animation][@"Shift"] doubleValue]];

        anim.fillMode = kCAFillModeBoth;
        
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [binLayer addAnimation:anim forKey:@"path"];
        
        binLayer.transform = currentTransform;
        
        binLayer.path = binPath.CGPath;
 
        if ( idx == _secondHighlightedBinIndex || idx == _highlightedBinIndex ) {
            
            CATextLayer *textLayer;
            if ( idx == _secondHighlightedBinIndex ) {
                textLayer = _secondHighlightedBinTextLayer;
                textLayer.string = _secondHighlightedBinText;
            } else if ( idx == _highlightedBinIndex ) {
                textLayer = _highlightedBinTextLayer;
                textLayer.string = _highlightedBinText;
            }
            
            CALayer *contentTextLayer = textLayer.superlayer;
            
            if ( contentTextLayer == nil ) {
                contentTextLayer = [CALayer new];
                contentTextLayer.anchorPoint = CGPointMake(0.0f, 0.5f);
                [contentTextLayer addSublayer:textLayer];
            }
            
            [binLayer addSublayer:contentTextLayer];
            
            contentTextLayer.transform = CATransform3DIdentity;
            contentTextLayer.frame = CGRectMake(binOriginX + finalBinWidth * 0.5f,
                                         binLayer.bounds.size.height - finalBinWidth * 0.5f,
                                         finalBinHeight,
                                         finalBinWidth);
            textLayer.transform = CATransform3DIdentity;
            CGFloat textHeight = textLayer.frame.size.height;
            textLayer.frame = CGRectMake(0.0f,
                                         (contentTextLayer.bounds.size.height - textHeight) / 2.0f,
                                         contentTextLayer.bounds.size.width,
                                         textHeight);
            textLayer.transform = _binTextTransform;
            contentTextLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
        } else {
            [[binLayer.sublayers firstObject] removeFromSuperlayer];
        }

    }];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callFinishBlock) object:nil];
    _finishBlock = nil;
    if ( finishBlock ) {
        _finishBlock = [finishBlock copy];
        NSTimeInterval time = [_animationOptions[animation][@"Duration"] doubleValue] + _bins.count * [_animationOptions[animation][@"Shift"] doubleValue];
        [self performSelector:@selector(callFinishBlock) withObject:nil afterDelay:time];
    }
}

- (void)callFinishBlock {
    HistogramFinishBlock tmpFinishBlock = _finishBlock;
    _finishBlock = nil;
    tmpFinishBlock(self);
}

#pragma mark - Utility

- (float)minBinCount {
    float currentMin = [_bins.firstObject binCount];
    for (HistogramBin *bin in _bins) {
        if ( bin.binCount < currentMin ) {
            currentMin = bin.binCount;
        }
    }
    
    return currentMin;
}

- (float)maxBinCount {
    float currentMax = [_bins.firstObject binCount];
    for (HistogramBin *bin in _bins) {
        if ( bin.binCount > currentMax ) {
            currentMax = bin.binCount;
        }
    }
    
    return currentMax;
}

- (float)minLeftBinEdge {
    return [_bins.firstObject leftEdge];
}

- (float)maxRightBinEdge {
    return [_bins.lastObject leftEdge];
}

- (CGColorRef)colorForBinLayer:(CAShapeLayer*)layer {
    if ( [_binLayers indexOfObject:layer] == _highlightedBinIndex ) {
        return _highlightedBinColor.CGColor;
    } else if ( [_binLayers indexOfObject:layer] == _secondHighlightedBinIndex ) {
        return _secondHighlightedBinColor.CGColor;
    } else {
        return _binColor.CGColor;
    }
}

- (CGFloat)scaleForBinLayer:(CAShapeLayer*)layer withTouchPoint:(CGPoint)touchPoint  {
    CGFloat applyRadius = 30.0f;
    CGFloat maxApplyScale = 1.5f;
    CGFloat minApplyScale = 1.0f;
    
    CGFloat xMiddle = CGRectGetMidX(CGPathGetPathBoundingBox(layer.path));
    CGFloat touchDiff = touchPoint.x - xMiddle;
    if ( touchDiff <= applyRadius && touchDiff >= 0 ) {
        return (maxApplyScale - minApplyScale) / applyRadius * xMiddle + (touchPoint.x * minApplyScale - (touchPoint.x - applyRadius) * maxApplyScale) / applyRadius;
    } else if ( touchDiff >= -applyRadius && touchDiff < 0 ) {
        return (maxApplyScale - minApplyScale) / (-applyRadius) * xMiddle + (touchPoint.x * minApplyScale - (touchPoint.x + applyRadius) * maxApplyScale) / (-applyRadius);
    } else {
        return minApplyScale;
    }
}

- (CGFloat)translationXForBinLayer:(CAShapeLayer*)layer withTouchPoint:(CGPoint)touchPoint  {
    CGFloat applyRadius = 30.0f;
    CGFloat maxApplyTranslation = 30.0f;
    CGFloat minApplyTranslation = -maxApplyTranslation;

    CGFloat xMiddle = CGRectGetMidX(CGPathGetPathBoundingBox(layer.path));
    //CGFloat xMiddle = CGRectGetMidX([_binRects[[_binLayers indexOfObject:layer]] CGRectValue]);
    CGFloat touchDiff = touchPoint.x - xMiddle;
    if ( touchDiff <= applyRadius && touchDiff >= -applyRadius ) {
        return (maxApplyTranslation - minApplyTranslation) / (applyRadius * 2.0f) * xMiddle + ((touchPoint.x + applyRadius) * minApplyTranslation - (touchPoint.x - applyRadius) * maxApplyTranslation) / (applyRadius * 2.0f);
    } else if ( touchDiff > applyRadius ) {
        return minApplyTranslation;
    } else  {
        return maxApplyTranslation;
    }
}

- (CGFloat)translationYForBinLayer:(CAShapeLayer*)layer withTouchPoint:(CGPoint)touchPoint  {
    CGFloat applyRadius = 30.0f;
    CGFloat maxApplyTranslation = -10.0f;
    CGFloat minApplyTranslation = 0;
    
    CGFloat xMiddle = CGRectGetMidX(CGPathGetPathBoundingBox(layer.path));
    CGFloat touchDiff = touchPoint.x - xMiddle;
    if ( touchDiff <= applyRadius && touchDiff >= 0 ) {
        return (maxApplyTranslation - minApplyTranslation) / applyRadius * xMiddle + (touchPoint.x * minApplyTranslation - (touchPoint.x - applyRadius) * maxApplyTranslation) / applyRadius;
    } else if ( touchDiff >= -applyRadius && touchDiff < 0 ) {
        return (maxApplyTranslation - minApplyTranslation) / (-applyRadius) * xMiddle + (touchPoint.x * minApplyTranslation - (touchPoint.x + applyRadius) * maxApplyTranslation) / (-applyRadius);
    } else {
        return minApplyTranslation;
    }
}

- (float)edgeValueForPoint:(CGPoint)point {
    float minValue = [self minLeftBinEdge];
    float maxValue = [self maxRightBinEdge];
    CGFloat width = _backLayer.bounds.size.width;
    return (maxValue - minValue) / width * point.x + (width * minValue) / width ;
}

#pragma mark - DynamicProperties

- (void)setBins:(NSArray *)bins {
    [self setBins:bins finishBlock:nil];
}

- (void)setBins:(NSArray *)bins finishBlock:(HistogramFinishBlock)finishBlock {
    _bins = [bins sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"leftEdge" ascending:YES]]];
    
    _highlightedBinIndex = NSNotFound;
    
    if ( _binLayers.count != _bins.count ) {
        [self removeBinLayers];
        [self layoutBinLayersWithAnimation:HistogramAnimationCreate finishBlock:finishBlock];
    } else {
        [self layoutBinLayersWithAnimation:HistogramAnimationUpdate finishBlock:finishBlock];
    }
}

- (void)setHighlightedBinIndex:(NSUInteger)highlightedBinIndex {
    if ( (highlightedBinIndex >= _bins.count && highlightedBinIndex != NSNotFound) || highlightedBinIndex == _highlightedBinIndex  ) {
        return;
    }
    
    NSUInteger oldHighlightIndex = _highlightedBinIndex;
    _highlightedBinIndex = highlightedBinIndex;
    
    if ( _highlightedBinIndex != NSNotFound ) {
        [_binLayers[_highlightedBinIndex] setFillColor:_highlightedBinColor.CGColor];
    }
    
    [self layoutBinLayersWithAnimation:HistogramAnimationSelection finishBlock:nil];
}

- (void)setHighlightedBinColor:(UIColor *)highlightedBinColor {
    _highlightedBinColor = highlightedBinColor;
    
    if ( _highlightedBinIndex != NSNotFound ) {
        [_binLayers[_highlightedBinIndex] setFillColor:_highlightedBinColor.CGColor];
    }
}

- (void)setSecondHighlightedBinIndex:(NSUInteger)secondHighlightedBinIndex {
    if ( secondHighlightedBinIndex >= _bins.count && secondHighlightedBinIndex != NSNotFound  ) {
        return;
    }
    
    NSUInteger oldHighlightIndex = _secondHighlightedBinIndex;
    _secondHighlightedBinIndex = secondHighlightedBinIndex;
    
    if ( _secondHighlightedBinIndex != NSNotFound ) {
        [_binLayers[_secondHighlightedBinIndex] setFillColor:_secondHighlightedBinColor.CGColor];
    }

    [self layoutBinLayersWithAnimation:HistogramAnimationSelection finishBlock:nil];
}

- (void)setSecondHighlightedBinColor:(UIColor *)secondHighlightedBinColor {
    _secondHighlightedBinColor = secondHighlightedBinColor;
    
    if ( _secondHighlightedBinIndex != NSNotFound ) {
        [_binLayers[_secondHighlightedBinIndex] setFillColor:_secondHighlightedBinColor.CGColor];
    }
    
}

- (void)setHighlightedBinText:(NSString *)highlightedBinText {
    _highlightedBinText = highlightedBinText;
    _highlightedBinTextLayer.string = _highlightedBinText;
}

- (void)setSecondHighlightedBinText:(NSString *)secondHighlightedBinText {
    _secondHighlightedBinText = secondHighlightedBinText;
    _secondHighlightedBinTextLayer.string = _secondHighlightedBinText;
}

- (void)setBinColor:(UIColor *)binColor {
    _binColor = binColor;
    
    for (CAShapeLayer *binLayer in _binLayers) {
        binLayer.fillColor = [self colorForBinLayer:binLayer];
    }
}

- (void)setSelectedWidth:(CGFloat)selectedWidth {
    _selectedWidth = selectedWidth;
    [self layoutBinLayersWithAnimation:HistogramAnimationNA finishBlock:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
