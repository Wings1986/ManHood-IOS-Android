//
//  PolarPlot.m
//  CoolHisto
//
//  Created by Viktor Gubriienko on 26.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import "PolarPlot.h"

@implementation PolarPlot {
    NSMutableArray *_dataViews;
    UIImageView *_backView;
}

#pragma mark - Init

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
    self.backgroundColor = [UIColor clearColor];
    
    _backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plot_bg.png"]];
    _backView.frame = self.bounds;
    _backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backView];
    
    _dataViews = [NSMutableArray new];
}

#pragma mark - Private

- (void)updateViews {
    
    for (PolarPlotData *data in _data) {
        UIImageView *view = [_dataViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d", data.ID]].firstObject;
        if ( view == nil ) {
            view = [[UIImageView alloc] initWithImage:data.image];
            view.center = [self centerFromData:data];
            view.alpha = 0.0f;
            view.tag = data.ID;
            [_dataViews addObject:view];
        }
        
        [self addSubview:view];
        
        [UIView animateWithDuration:0.05
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             view.center = [self centerFromData:data];
                             view.alpha = 0.9f;
                         } completion:nil];
    }
    
    for (UIImageView *view in [_dataViews copy]) {
        if ( [_data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %d", view.tag]].count == 0) {
            [UIView animateWithDuration:0.05
                             animations:^{
                                 view.alpha = 0.0f;
                                 [_dataViews removeObject:view];
                             } completion:^(BOOL finished) {
                                 [view removeFromSuperview];
                             }];
        }
    }
}

- (CGPoint)centerFromData:(PolarPlotData*)data {
    CGFloat ratio = 75.0f;
    return CGPointMake(sin(data.point.y * M_PI / 180.0f) * cos(data.point.x * M_PI / 180.0f) * ratio + CGRectGetMidX(self.bounds),
                       sin(data.point.y * M_PI / 180.0f) * sin(data.point.x * M_PI / 180.0f) * ratio + CGRectGetMidX(self.bounds));
}

#pragma mark - DynamicProperties

- (void)setData:(NSArray *)data {
    _data = [data sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES]]];
    
    [self updateViews];
    
}

@end
