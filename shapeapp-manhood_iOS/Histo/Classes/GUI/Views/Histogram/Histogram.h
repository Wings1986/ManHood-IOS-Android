//
//  Histogram.h
//  CoolHisto
//
//  Created by Viktor Gubriienko on 18.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistogramBin.h"

typedef enum : NSUInteger {
    HistogramSelectionStateSelected,
    HistogramSelectionStateNotSelected,
    HistogramSelectionStateDelayedFinish,
} HistogramSelectionState;

@class Histogram;
typedef void(^HistogramFinishBlock)(Histogram *sender);

@interface Histogram : UIView

@property (nonatomic) BOOL animated;
@property (nonatomic, copy) NSArray *bins;
@property (nonatomic, strong) UIColor *binColor;
@property (nonatomic, readonly) BOOL selecting;

@property (nonatomic) CATransform3D binTextTransform;
@property (nonatomic) BOOL shouldMaxSelectedBinHeight;
@property (nonatomic) CGFloat selectedWidth;

@property (nonatomic) NSUInteger highlightedBinIndex;
@property (nonatomic, strong) UIColor *highlightedBinColor;
@property (nonatomic, strong) NSString *highlightedBinText;

@property (nonatomic) NSUInteger secondHighlightedBinIndex;
@property (nonatomic, strong) UIColor *secondHighlightedBinColor;
@property (nonatomic, strong) NSString *secondHighlightedBinText;



@property (nonatomic, copy) void(^valueSelectionChangedBlock)(Histogram *sender, HistogramSelectionState selectionState, float selectedValue, HistogramBin *selectedBin);

- (void)setBins:(NSArray *)bins finishBlock:(HistogramFinishBlock)finishBlock;
- (void)cancelEndPanAction;

@end
