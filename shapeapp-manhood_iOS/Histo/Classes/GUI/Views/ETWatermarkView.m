//
//  ETWatermarkView.m
//  Histo
//
//  Created by Viktor Gubriienko on 15.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETWatermarkView.h"

@implementation ETWatermarkView

- (void)drawRect:(CGRect)rect {
    
    CGSize textSize = _text.size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    CGFloat shiftStep = 30.0f;
    NSInteger lines = ceilf(self.bounds.size.height / textSize.height);
    NSInteger columns = ceilf(self.bounds.size.width / textSize.width) + 1;
    
    CGPoint origin = CGPointZero;
    for (NSInteger i = 0; i < lines; i++) {
        
        CGFloat shift = i * shiftStep;
        if ( shift >= textSize.width ) {
            shift -= textSize.width;
        }
        
        for (NSInteger j = 0; j < columns; j++) {
            [_text drawInRect:CGRectMake(j * textSize.width - shift,
                                         i * textSize.height,
                                         textSize.width,
                                         textSize.height)];
        }
    }
}

#pragma mark - DynamicProperties

- (void)setText:(NSAttributedString *)text {
    _text = [text copy];
    [self setNeedsDisplay];
}

@end
