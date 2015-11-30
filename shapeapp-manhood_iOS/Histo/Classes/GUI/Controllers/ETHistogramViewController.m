//
//  ETHistogramViewController.m
//  Histo
//
//  Created by Idriss on 18/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETHistogramViewController.h"
#import "NSUserDefaults+Preferences.h"
#import "ETShareUtility.h"
#import "TransitionManager.h"
#import "ETUnitConverter.h"
#import "Histogram.h"
#import "PolarPlot.h"
#import "UsersData.h"
#import "SelfUserData.h"
#import "ETDataModel.h"
#import "ETCertificateViewController.h"
#import "ETStore.h"
#import "ETRequestManager.h"
#import "MBProgressHUD.h"
#import "ETGeolocation.h"
#import "Appirater.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "AFNetworkReachabilityManager.h"

static const float kSwitchOrigins[] = {3.0f, 57.0f, 112.0f};

typedef enum : NSUInteger {
    OfflineModeNo,
    OfflineModeSoft,
    OfflineModeFull,
} OfflineMode;

@interface ETHistogramViewController ()

<
UIScrollViewDelegate,
UIViewControllerTransitioningDelegate
>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) SliceRange selectedRange;
@property (nonatomic) OfflineMode offlineMode;

@property (nonatomic, strong) TransitionManager *transitionManager;
@property (weak, nonatomic) IBOutlet UIImageView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *switchSelectorView;
@property (weak, nonatomic) IBOutlet UILabel *switchAllTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *switch200TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *switch20TitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *youButton;

@property (weak, nonatomic) IBOutlet Histogram *lengthHisto;
@property (weak, nonatomic) IBOutlet Histogram *girthHisto;
@property (weak, nonatomic) IBOutlet Histogram *thicknessHisto;
@property (weak, nonatomic) IBOutlet PolarPlot *polarPlot;

@property (weak, nonatomic) IBOutlet UIView *textBoxView;
@property (weak, nonatomic) IBOutlet UILabel *lengthSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *girthSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *thicknessSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *curvedSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *textBoxTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *textBoxSubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textBoxSubtitleValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthTOPLabel;
@property (weak, nonatomic) IBOutlet UILabel *girthTOPLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinkestAtTOPLabel;
@property (weak, nonatomic) IBOutlet UILabel *curvedTOPLabel;


// Data
@property (nonatomic, strong) NSString *nearestUserID;
@property (nonatomic, strong) UsersData *usersData;
@property (nonatomic, strong) SelfUserData *selfUserData;

- (IBAction)panRangeSwitch:(UIPanGestureRecognizer *)sender;
- (IBAction)tapRangeSwitch:(UITapGestureRecognizer *)sender;

- (IBAction)youTouchDown:(UIButton *)sender;
- (IBAction)youTouchUp:(UIButton *)sender;

@end



@implementation ETHistogramViewController {
    BOOL _firstAppear;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [NSObject dispatchAfter:10 block:^{
//        [[ETStore sharedInstance] purchaseOneMonthSubscription];
//    }];
    
    [self setupViews];
    
    _selectedRange = -1;
    self.transitionManager = [TransitionManager new];
    [_youButton setBackgroundImage:[_youButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"histogram_bg-568h.png"]:[UIImage imageNamed:@"histogram_bg.png"];
    _backView.image = image;
    
    [self showUserParametersWithAnimation:NO];
    
    _firstAppear = YES;
    
    [[ETDataModel sharedInstance] addObserver:self
                                   forKeyPath:NSStringFromSelector(@selector(userData))
                                      options:0
                                      context:nil];
    
    [NSObject dispatchAfter:0 block:^{
        __weak typeof(self) weakSelf = self;
        [[ETDataModel sharedInstance] doStartupFlow:^(BOOL success, NSError *error) {
            self.selectedRange = 0;
            if ( success ) {
                [weakSelf updateViewsData];
            }
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] privacyLock]) {
        /* hide you button when Privacy Lock is on*/
        self.youButton.hidden = YES;
    } else if ([[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userFemale]) {
        /* hide you button when user is female*/
        self.youButton.hidden = YES;
    } else {
        self.youButton.hidden = NO;
    }
    
    if ( _firstAppear ) {
        _firstAppear = NO;
    } else {
        [self setSelectionForAverage];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"Certificate"] ) {
        ETCertificateViewController *certificateCtrl = segue.destinationViewController;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"All_json" ofType:@"txt"];
        UsersData *allUsersData = [[UsersData alloc] initWithContentsOfFile:filePath
                                                                    rootKey:@"All"];
        
        [certificateCtrl setUsersData:allUsersData selfUserData:_selfUserData];
    }
}

#pragma mark -

- (void)showClosestNeedMesurementMessage {
    [UIAlertView showWithTitle:@"Measurement needed to see the Area around you"
                       message:@"To see the close by, you need to get yourself measured"
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@[@"How-To"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"How-To"] ) {
                              UIViewController *guideCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"GuideNavCtrl"];
                              guideCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                              [self presentViewController:guideCtrl animated:YES completion:nil];
                          }
                      }];
}

- (void)showMesurementMessage {
    [UIAlertView showWithTitle:@"Get your ManHood measured"
                       message:@"To measure up, you need to get yourself measured"
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@[@"How-To"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"How-To"] ) {
                              UIViewController *guideCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"GuideNavCtrl"];
                              guideCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                              [self presentViewController:guideCtrl animated:YES completion:nil];
                          }
                      }];
}

#pragma mark - Private

- (void)updateRangeSwitch {
    
    NSArray *labels = @[_switchAllTitleLabel, _switch200TitleLabel, _switch20TitleLabel];
    
    CGRect frame = _switchSelectorView.frame;
    
    frame.origin.x = kSwitchOrigins[_selectedRange];
    
    [UIView animateWithDuration:0.2
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         for (UILabel *label in labels) {
                             label.font = [UIFont fontWithName:@"Exo-Regular" size:17.0f];
                             label.alpha = 0.8f;
                         }
                         
                         UILabel *selectedLabel = labels[_selectedRange];
                         selectedLabel.font = [UIFont fontWithName:@"Exo-Medium" size:17.0f];
                         selectedLabel.alpha = 1.0f;
                         
                         _switchSelectorView.frame = frame;
                         
                     } completion:nil];
}

- (void)recognizeSwitchTouch:(CGPoint)touch {
    NSInteger switchCount = 3;
    for (NSInteger i = 0 ; i < switchCount; i++) {
        if ( i == switchCount - 1 ) {
            self.selectedRange = i;
            break;
        }
        
        CGFloat originX = kSwitchOrigins[i + 1];
        
        if ( touch.x < originX ) {
            self.selectedRange = i;
            break;
        }
    };

}

- (void)setupViews {
    
    __weak typeof(self) weakSelf = self;
    
    _lengthHisto.shouldMaxSelectedBinHeight = YES;
    _girthHisto.shouldMaxSelectedBinHeight = YES;
    _thicknessHisto.shouldMaxSelectedBinHeight = YES;
    
    CGRect frame = _thicknessHisto.bounds;
    frame.size = CGSizeMake(frame.size.height, frame.size.width);
    _thicknessHisto.bounds = frame;
    _thicknessHisto.transform = CGAffineTransformScale( CGAffineTransformMakeRotation(M_PI_2), -1.0f, 1.0f);
    _thicknessHisto.binTextTransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
    
    frame = _lengthHisto.bounds;
    frame.size = CGSizeMake(frame.size.height, frame.size.width);
    _lengthHisto.bounds = frame;
    _lengthHisto.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _lengthHisto.binTextTransform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    [_lengthHisto setValueSelectionChangedBlock:^(Histogram *histo, HistogramSelectionState selectionState, float value, HistogramBin *bin) {

        switch (selectionState) {
            case HistogramSelectionStateSelected: {
                weakSelf.nearestUserID = [weakSelf.usersData userIDWithNearestLength:value];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.girthHisto
                              forValue:[weakSelf.usersData girthOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.thicknessHisto
                              forValue:[weakSelf.usersData thicknessOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:NO onBinForHistogram:weakSelf.lengthHisto forValue:0.0f];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateNotSelected: {
                weakSelf.nearestUserID = nil;
                [weakSelf setSelectionForAverage];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateDelayedFinish: {
                
            } break;
        }
        
        weakSelf.girthHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;
        weakSelf.thicknessHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;
    }];
    
    [_girthHisto setValueSelectionChangedBlock:^(Histogram *histo, HistogramSelectionState selectionState, float value, HistogramBin *bin) {
        
        switch (selectionState) {
            case HistogramSelectionStateSelected: {
                weakSelf.nearestUserID = [weakSelf.usersData userIDWithNearestGirth:value];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.thicknessHisto
                              forValue:[weakSelf.usersData thicknessOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.lengthHisto
                              forValue:[weakSelf.usersData lengthOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:NO onBinForHistogram:weakSelf.girthHisto forValue:0.0f];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateNotSelected: {
                weakSelf.nearestUserID = nil;
                [weakSelf setSelectionForAverage];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateDelayedFinish: {
                
            } break;
        }
        
        weakSelf.lengthHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;
        weakSelf.thicknessHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;

    }];
    
    [_thicknessHisto setValueSelectionChangedBlock:^(Histogram *histo, HistogramSelectionState selectionState, float value, HistogramBin *bin) {
        
        switch (selectionState) {
            case HistogramSelectionStateSelected: {
                weakSelf.nearestUserID = [weakSelf.usersData userIDWithNearestThickness:value];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.girthHisto
                              forValue:[weakSelf.usersData girthOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:YES
                     onBinForHistogram:weakSelf.lengthHisto
                              forValue:[weakSelf.usersData lengthOfUserWithID:weakSelf.nearestUserID]];
                
                [weakSelf setSelection:NO onBinForHistogram:weakSelf.thicknessHisto forValue:0.0f];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateNotSelected: {
                weakSelf.nearestUserID = nil;
                [weakSelf setSelectionForAverage];
                [weakSelf setupPolarPlotWithCurrentUserID:weakSelf.nearestUserID usersData:weakSelf.usersData selfUserData:weakSelf.selfUserData];
            } break;
            case HistogramSelectionStateDelayedFinish: {
                
            } break;
        }

        weakSelf.lengthHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;
        weakSelf.girthHisto.userInteractionEnabled = selectionState != HistogramSelectionStateSelected;

    }];
    
}

- (void)updateViewsData {

    _selfUserData = [ETDataModel sharedInstance].userData;
    _usersData = [self usersDataForSliceRange:(SliceRange)self.selectedRange];
    
    if ( _usersData == nil ) {
        self.offlineMode = OfflineModeFull;
    } else if ( ![AFNetworkReachabilityManager sharedManager].reachable && (_selectedRange == SliceRange20 || _selectedRange == SliceRange200) )
    {
        self.offlineMode = OfflineModeSoft;
    }
    
    __weak typeof(self) weakSelf = self;
    _lengthHisto.bins = [self createBinsFromEdges:_usersData.lengthBins counts:_usersData.lengthCounts];
    _girthHisto.bins = [self createBinsFromEdges:_usersData.girthBins counts:_usersData.girthCounts];
    [_thicknessHisto setBins:[self createBinsFromEdges:_usersData.thicknessBins counts:_usersData.thicknessCounts]
                 finishBlock:^(Histogram *sender) {
                     [weakSelf setSelectionForAverage];
                 }];

}

- (NSArray*)createBinsFromEdges:(NSArray*)edges counts:(NSArray*)counts {
    NSMutableArray *bins = [NSMutableArray new];
    for (NSInteger i = 0; i < counts.count ; i++) {
        HistogramBin *bin = [HistogramBin histogramBinWithLeftEdge:[edges[i] floatValue]
                                                         rightEdge:[edges[i+1] floatValue]
                                                          binCount:[counts[i] floatValue]];
        [bins addObject:bin];
    }
    
    return bins;
}

- (void)setupPolarPlotWithCurrentUserID:(NSString*)userID
                              usersData:(UsersData*)usersData
                           selfUserData:(SelfUserData*)selfUserData
{
    NSMutableArray *plotData = [NSMutableArray new];
    
    if ( userID ) {
        [plotData addObjectsFromArray:[self plotDataForUserWithID:userID usersData:usersData]];
    }
    
    if ( _youButton.selected ) {
        [plotData addObjectsFromArray:[self plotDataForSelfUserData:selfUserData]];
    }
    
    _polarPlot.data = plotData;
    
}

- (NSUInteger)binIndexForValue:(float)value fromEdges:(NSArray*)edges {
    
    if ( value < [edges.firstObject floatValue] || value > [edges.lastObject floatValue] ) {
        return NSNotFound;
    }
    
    __block NSInteger result = NSNotFound;
    [edges enumerateObjectsUsingBlock:^(NSNumber *edgeValue, NSUInteger idx, BOOL *stop) {
        
        if ( idx == 0 ) {
            return;
        }
        
        if ( value <= [edgeValue floatValue] ) {
            *stop = YES;
            result = idx - 1;
            return;
        }
    }];
    
    return result;
}

- (NSArray*)plotDataForUserWithID:(NSString*)userID usersData:(UsersData*)usersData {
    
    PolarPlotData *base = [PolarPlotData new];
    base.image = [UIImage imageNamed:@"g_circle_b.png"];
    base.point = [usersData basePositionOfUserWithID:userID];
    base.ID = 0;
    
    PolarPlotData *mid = [PolarPlotData new];
    mid.image = [UIImage imageNamed:@"g_circle_m.png"];
    mid.point = [usersData midPositionOfUserWithID:userID];
    mid.ID = 2;
    
    PolarPlotData *upper = [PolarPlotData new];
    upper.image = [UIImage imageNamed:@"g_circle_s.png"];
    upper.point = [usersData upperPositionOfUserWithID:userID];
    upper.ID = 4;
    
    PolarPlotData *tip = [PolarPlotData new];
    tip.image = [UIImage imageNamed:@"g_circle_smaller.png"];
    tip.point = [usersData tipPositionOfUserWithID:userID];
    tip.ID = 6;
    
    return @[base, mid, upper, tip];
    
}

- (NSArray*)plotDataForSelfUserData:(SelfUserData*)userData {
    
    PolarPlotData *base = [PolarPlotData new];
    base.image = [UIImage imageNamed:@"b_circle_b.png"];
    base.point = userData.basePosition;
    base.ID = 1;
    
    PolarPlotData *mid = [PolarPlotData new];
    mid.image = [UIImage imageNamed:@"b_circle_m.png"];
    mid.point = userData.midPosition;
    mid.ID = 3;
    
    PolarPlotData *upper = [PolarPlotData new];
    upper.image = [UIImage imageNamed:@"b_circle_s.png"];
    upper.point = userData.upperPosition;
    upper.ID = 5;
    
    PolarPlotData *tip = [PolarPlotData new];
    tip.image = [UIImage imageNamed:@"b_circle_smaller.png"];
    tip.point = userData.tipPosition;
    tip.ID = 7;
    
    return @[base, mid, upper, tip];
    
}

- (void)setSelection:(BOOL)selection onBinForHistogram:(Histogram*)histogram forValue:(float)value {
    if ( selection ) {
        
        __block NSUInteger binIndex = NSNotFound;
        [histogram.bins enumerateObjectsUsingBlock:^(HistogramBin *bin, NSUInteger idx, BOOL *stop) {
            if ( value >= bin.leftEdge && value < bin.rightEdge ) {
                binIndex = idx;
                *stop = YES;
            }
        }];

        [histogram cancelEndPanAction];
        
        if ( binIndex != NSNotFound ) {
            ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];
            
            histogram.highlightedBinIndex = binIndex;
            if ( histogram == _thicknessHisto ) {
                histogram.highlightedBinText = [ETDataModel fractionForValue:value];
            } else {
                histogram.highlightedBinText = [NSString stringWithFormat:@"%0.1f %@",
                                                [ETUnitConverter convertCMValue:value toUnit:unit],
                                                [ETUnitConverter nameForUnitType:unit]];
            }
        }
    } else {
        histogram.highlightedBinIndex = NSNotFound;
    }
}

- (void)setSelection:(BOOL)selection withUsersData:(UsersData*)usersData withSelfUserData:(SelfUserData*)selfUserData {
    if ( selection ) {
        
        ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];
        
        NSUInteger lengthBinIndex = [self binIndexForValue:[selfUserData length] fromEdges:usersData.lengthBins];
        if ( lengthBinIndex != NSNotFound ) {
            _lengthHisto.secondHighlightedBinIndex = lengthBinIndex;
            _lengthHisto.secondHighlightedBinText = [NSString stringWithFormat:@"%0.1f %@",
                                                     [ETUnitConverter convertCMValue:[selfUserData length] toUnit:unit],
                                                     [ETUnitConverter nameForUnitType:unit]];
        }
        NSUInteger girthBinIndex = [self binIndexForValue:[selfUserData girth] fromEdges:usersData.girthBins];
        if ( girthBinIndex != NSNotFound ) {
            _girthHisto.secondHighlightedBinIndex = girthBinIndex;
            _girthHisto.secondHighlightedBinText = [NSString stringWithFormat:@"%0.1f %@",
                                                    [ETUnitConverter convertCMValue:[selfUserData girth] toUnit:unit],
                                                    [ETUnitConverter nameForUnitType:unit]];
        }
        NSUInteger thicknessBinIndex = [self binIndexForValue:[selfUserData thickness] fromEdges:usersData.thicknessBins];
        if ( thicknessBinIndex != NSNotFound ) {
            _thicknessHisto.secondHighlightedBinIndex = thicknessBinIndex;
            _thicknessHisto.secondHighlightedBinText = [ETDataModel fractionForValue:[selfUserData thickness]];
        }
    } else {
        _lengthHisto.secondHighlightedBinIndex = NSNotFound;
        _girthHisto.secondHighlightedBinIndex = NSNotFound;
        _thicknessHisto.secondHighlightedBinIndex = NSNotFound;
    }
}

- (void)setSelectionForAverage {
    [self setSelection:YES onBinForHistogram:_lengthHisto forValue:_usersData.averageLength];
    [self setSelection:YES onBinForHistogram:_girthHisto forValue:_usersData.averageGirth];
    [self setSelection:YES onBinForHistogram:_thicknessHisto forValue:_usersData.averageThickness];
}

- (void)unselectAll {
    [self setSelection:NO onBinForHistogram:_lengthHisto forValue:0.0f];
    [self setSelection:NO onBinForHistogram:_girthHisto forValue:0.0f];
    [self setSelection:NO onBinForHistogram:_thicknessHisto forValue:0.0f];
}

- (void)showUserParametersWithAnimation:(BOOL)animate {

    [UIView animateWithDuration:(animate) ? 0.2 : 0.0
                     animations:^{
                         
                         if ( self.nearestUserID == nil || _youButton.selected ) {
                             _textBoxSubtitleLabel.alpha = 0.0f;
                             _textBoxSubtitleValueLabel.alpha = 0.0f;
                         } else {
                             _textBoxSubtitleLabel.alpha = 1.0f;
                             _textBoxSubtitleValueLabel.alpha = 1.0f;
                             
                             ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];
                             float value = 0.0f;
                             if ( _lengthHisto.selecting ) {
                                 _textBoxSubtitleLabel.text = @"LENGTH";
                                 value = [_usersData lengthOfUserWithID:self.nearestUserID];
                                 _textBoxSubtitleValueLabel.text = [NSString stringWithFormat:@"%0.1f %@",
                                                                    [ETUnitConverter convertCMValue:value toUnit:unit],
                                                                    [ETUnitConverter nameForUnitType:unit]];
                             } else if ( _girthHisto.selecting ) {
                                 _textBoxSubtitleLabel.text = @"THICKNESS";
                                 value = [_usersData girthOfUserWithID:self.nearestUserID];
                                 _textBoxSubtitleValueLabel.text = [NSString stringWithFormat:@"%0.1f %@",
                                                                   [ETUnitConverter convertCMValue:value toUnit:unit],
                                                                    [ETUnitConverter nameForUnitType:unit]];
                             } else if ( _thicknessHisto.selecting ) {
                                 _textBoxSubtitleLabel.text = @"THICKEST AT";
                                 value = [_usersData thicknessOfUserWithID:self.nearestUserID];
                                 _textBoxSubtitleValueLabel.text = [ETDataModel fractionForValue:value];
                             }
                         }
                         
                         NSString *lengthStr;
                         NSString *girthStr;
                         NSString *thinknessStr;
                         NSString *curvedStr;
                         NSString *title;
                         
                         if ( self.offlineMode == OfflineModeFull ) { // NO connection state
                             _lengthTOPLabel.hidden = YES;
                             _thinkestAtTOPLabel.hidden = YES;
                             _girthTOPLabel.hidden = YES;
                             _curvedTOPLabel.hidden = YES;
                             
                             BOOL hasLocation = [ETGeolocation sharedInstance].currentLocation != nil;
                             title = hasLocation ? @"NO CONNECTION" : @"NO LOCATION" ;
                             lengthStr = @"...";
                             girthStr = @"...";
                             thinknessStr = @"...";
                             curvedStr = @"...";
                             
                         } else if ( _youButton.selected ) {
                             if (self.nearestUserID == nil) { // Histogram not selected
                                 title = @"YOUR POSITION";
                                 
                                 _lengthTOPLabel.hidden = NO;
                                 _thinkestAtTOPLabel.hidden = NO;
                                 _girthTOPLabel.hidden = NO;
                                 _curvedTOPLabel.hidden = NO;
                                 
                                 NSString *nearestLengthUserID = [_usersData userIDWithNearestLength:_selfUserData.length];
                                 NSString *nearestGirthUserID = [_usersData userIDWithNearestGirth:_selfUserData.girth];
                                 NSString *nearestThinknessUserID = [_usersData userIDWithNearestThickness:_selfUserData.thickness];
                                 
                                 float lengthPosition = (float)[_usersData positionByLengthOfUserWithID:nearestLengthUserID] / _usersData.usersCount * 100;
                                 float girthPosition = (float)[_usersData positionByGirthOfUserWithID:nearestGirthUserID] / _usersData.usersCount * 100;
                                 float thinknessPosition = (float)[_usersData positionByThicknessOfUserWithID:nearestThinknessUserID] / _usersData.usersCount * 100;
                                 float curved = _selfUserData.tipPosition.y;
                                 
                                 lengthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(lengthPosition)];
                                 girthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(girthPosition)];
                                 thinknessStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(thinknessPosition)];
                                 curvedStr = [NSString stringWithFormat:@"%.0f˚", floorf(curved)];
                                 
                             } else {
                                 title = @"DIFFERENCE"; // before @"YOU & THIS GUY"
                                 
                                 _lengthTOPLabel.hidden = YES;
                                 _thinkestAtTOPLabel.hidden = YES;
                                 _girthTOPLabel.hidden = YES;
                                 _curvedTOPLabel.hidden = YES;
                                 
                                 NSString *nearestLengthUserID = [_usersData userIDWithNearestLength:_selfUserData.length];
                                 NSString *nearestGirthUserID = [_usersData userIDWithNearestGirth:_selfUserData.girth];
                                 NSString *nearestThinknessUserID = [_usersData userIDWithNearestThickness:_selfUserData.thickness];
                                 
                                 float yourCurved = _selfUserData.tipPosition.y;

                                 float lengthDifference = (float)[_usersData lengthOfUserWithID:nearestLengthUserID] - (float)[_usersData lengthOfUserWithID:self.nearestUserID];
                                 float girthDifference = (float)[_usersData girthOfUserWithID:nearestGirthUserID] - (float)[_usersData girthOfUserWithID:self.nearestUserID];
                                 float thinknessDifference = (float)[_usersData thicknessOfUserWithID:nearestThinknessUserID] - (float)[_usersData thicknessOfUserWithID:self.nearestUserID];
                                 
                                 float curved = [_usersData tipPositionOfUserWithID:self.nearestUserID].y;
                                 
                                 ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];

                                 lengthStr = [NSString stringWithFormat:@"%0.1f %@",
                                              [ETUnitConverter convertCMValue:lengthDifference toUnit:unit],
                                                                    [ETUnitConverter nameForUnitType:unit]];
                                 girthStr = [NSString stringWithFormat:@"%0.1f %@",
                                             [ETUnitConverter convertCMValue:girthDifference toUnit:unit],
                                             [ETUnitConverter nameForUnitType:unit]];
                                 thinknessStr = [ETDataModel fractionForValue:thinknessDifference];
                                 curvedStr = [NSString stringWithFormat:@"%.0f˚", floorf(yourCurved) - floorf(curved)];
                                 
                             }
                         } else {
                             
                             _lengthTOPLabel.hidden = NO;
                             _thinkestAtTOPLabel.hidden = NO;
                             _girthTOPLabel.hidden = NO;
                             _curvedTOPLabel.hidden = NO;
                             
                             if (self.nearestUserID == nil) { // Histogram not selected
                                 title = @"AVERAGE";
                                 float lengthPosition = 50.0f;
                                 float girthPosition = 50.0f;
                                 float thinknessPosition = 50.0f;
                                 float curved = 0.0f;
                                 
                                 lengthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(lengthPosition)];
                                 girthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(girthPosition)];
                                 thinknessStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(thinknessPosition)];
                                 curvedStr = [NSString stringWithFormat:@"%.0f˚", floorf(curved)];
                             } else {
                                 title = @"DATA POINT"; //before @"THIS GUY";
                                 
                                 float lengthPosition = (float)[_usersData positionByLengthOfUserWithID:self.nearestUserID] / _usersData.usersCount * 100;
                                 float girthPosition = (float)[_usersData positionByGirthOfUserWithID:self.nearestUserID] / _usersData.usersCount * 100;
                                 float thinknessPosition = (float)[_usersData positionByThicknessOfUserWithID:self.nearestUserID] / _usersData.usersCount * 100;
                                 float curved = [_usersData tipPositionOfUserWithID:self.nearestUserID].y;
                                 
                                 lengthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(lengthPosition)];
                                 girthStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(girthPosition)];
                                 thinknessStr = [NSString stringWithFormat:@"%ld%%", 100 - (long)roundf(thinknessPosition)];
                                 curvedStr = [NSString stringWithFormat:@"%.0f˚", floorf(curved)];
                             }
                         }
                         
                         _textBoxTitleLabel.text = title;
                         _lengthSelectedLabel.text = lengthStr;
                         _girthSelectedLabel.text = girthStr;
                         _thicknessSelectedLabel.text = thinknessStr;
                         _curvedSelectedLabel.text = curvedStr;
                         
                     }];
}

- (UsersData*)usersDataForSliceRange:(SliceRange)range {
    switch (range) {
        case SliceRangeAll: {
            return [ETDataModel sharedInstance].usersDataAll;
        } break;
        case SliceRange200: {
            return [ETDataModel sharedInstance].usersData200;
        } break;
        case SliceRange20: {
            return [ETDataModel sharedInstance].usersData20;
        } break;
        default:
            return nil;
            break;
    }
}

- (UIImage*)makeSnapshot {
    
    UIImage *logo = [UIImage imageNamed:@"manHoodLogo.png"];
    CGSize imageSize = _contentView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [_backView.image drawAtPoint:CGPointMake(0.0f, -64.0f)];
    [[_contentView.layer presentationLayer] renderInContext:ctx];
    [logo drawAtPoint:CGPointMake(7.0f, imageSize.height - logo.size.height - 4.0f)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - Actions

- (IBAction)share:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"        // Event category (required)
                                                          action:@"user_action"      // Event action (required)
                                                           label:@"histogram_share"  // Event label
                                                           value:nil] build]];       // Event value
    
    UIImage *snapshot = [self makeSnapshot];
    [ETShareUtility shareHistogramSnapshot:snapshot onViewController:self];
}

- (IBAction)youTouchDown:(UIButton *)sender {
    
    if ( _selfUserData == nil ) {
        [self showMesurementMessage];
        return;
    }
    
    sender.selected = YES;
    [self setupPolarPlotWithCurrentUserID:self.nearestUserID usersData:_usersData selfUserData:_selfUserData];
    [self setSelection:sender.selected withUsersData:self.usersData withSelfUserData:self.selfUserData];
    [self showUserParametersWithAnimation:YES];
    
    if ( !self.nearestUserID ) {
        [self setSelection:NO onBinForHistogram:_lengthHisto forValue:0.0f];
        [self setSelection:NO onBinForHistogram:_girthHisto forValue:0.0f];
        [self setSelection:NO onBinForHistogram:_thicknessHisto forValue:0.0f];
    }
}

- (IBAction)youTouchUp:(UIButton *)sender {
    sender.selected = NO;
    [self setupPolarPlotWithCurrentUserID:self.nearestUserID usersData:_usersData selfUserData:_selfUserData];
    [self setSelection:sender.selected withUsersData:self.usersData withSelfUserData:self.selfUserData];
    [self showUserParametersWithAnimation:YES];
    if ( !self.nearestUserID ) {
        [self setSelectionForAverage];
    }

}

#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.transitionTo = MODAL;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.transitionTo = INITIAL;
    return self.transitionManager;
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [keyPath isEqualToString:NSStringFromSelector(@selector(userData))] ) {
        _selfUserData = [ETDataModel sharedInstance].userData;
    }
}

#pragma mark - Recognizers

- (IBAction)panRangeSwitch:(UIPanGestureRecognizer *)sender {
    
    static CGFloat startPositionX;
    
    if ( sender.state == UIGestureRecognizerStateBegan ) {
        if ( ![_switchSelectorView pointInside:[sender locationInView:_switchSelectorView] withEvent:nil] ) {
            sender.enabled = NO;
            sender.enabled = YES;
        }
        
        startPositionX = _switchSelectorView.frame.origin.x;
        
    } else if ( sender.state == UIGestureRecognizerStateChanged ) {
        
        CGPoint translation = [sender translationInView:sender.view];
        CGRect frame = _switchSelectorView.frame;
        frame.origin.x = MAX(startPositionX + translation.x, kSwitchOrigins[0]) ;
        frame.origin.x = MIN(frame.origin.x, kSwitchOrigins[2]) ;
        _switchSelectorView.frame = frame;
        
    } else if ( sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled  ) {
        CGPoint touch = [sender locationInView:sender.view];
        [self recognizeSwitchTouch:touch];
    }
}

- (IBAction)tapRangeSwitch:(UITapGestureRecognizer *)sender {
    
    if ( sender.state != UIGestureRecognizerStateRecognized ) {
        return;
    }
    
    CGPoint touch = [sender locationInView:sender.view];
    
    [self recognizeSwitchTouch:touch];
    
}

- (IBAction)swipeScreen:(UISwipeGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        [self performSegueWithIdentifier:@"Certificate" sender:self];
    }
}
- (IBAction)swipeToSettings:(UISwipeGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        [self performSegueWithIdentifier:@"Settings" sender:self];
    }
}

#pragma mark - DynamicProperties

- (void)setSelectedRange:(SliceRange)selectedRange {
    
    if ( selectedRange > 2) {
        return;
    }
    
    self.offlineMode = NO;
    
    ETDataModel *dataModel = [ETDataModel sharedInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL male = [userDefaults.userGender isEqualToString:userMale];
    BOOL female = !male;

    BOOL shouldIgnore = selectedRange == _selectedRange;
    NSInteger oldSelectedRange = _selectedRange;
    _selectedRange = selectedRange;
    
    if ( shouldIgnore ) {
        
    } else if ( male ) {
        if ( _selfUserData == nil ) {
            if ( _selectedRange == SliceRange200 || _selectedRange == SliceRange20 ) {
                [self showClosestNeedMesurementMessage];
                shouldIgnore = YES;
            }
        } else {
            if ( _selectedRange == SliceRange20 ) {
                if ( !userDefaults.isSubscriptionValid ) {
                    shouldIgnore = YES;
                    [dataModel showInAppPurchaseSuccess:^{
                        self.selectedRange = SliceRange20;
                    }];
                }
            }
        }
    } else {
        if ( _selectedRange == SliceRange20 ) {
            if ( !userDefaults.isSubscriptionValid ) {
                shouldIgnore = YES;
                [dataModel showInAppPurchaseSuccess:^{
                    self.selectedRange = SliceRange20;
                }];
            }
        }
    }
    
    if ( shouldIgnore ) {
        _selectedRange = oldSelectedRange;
         [self updateRangeSwitch];
        return;
    }
    
    [self updateRangeSwitch];

    if (_selectedRange == SliceRange20 || _selectedRange == SliceRange200) {
        [Appirater userDidSignificantEvent:YES];
    }
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    NSString *group = [dataModel groupFromSliceRange:_selectedRange];
    if ( (_selectedRange == SliceRange20 || _selectedRange == SliceRange200) && [dataModel usersDataForGroup:group] == nil && [ETGeolocation sharedInstance].currentLocation == nil ) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        self.offlineMode = OfflineModeFull;
        [self updateViewsData];
    } else {
        [[ETDataModel sharedInstance] downloadHistogramDataForSliceRange:_selectedRange
                                                             finishBlock:^(BOOL success, NSError *error) {
                                                                 [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
                                                                 [self updateViewsData];
                                                             }];
    }
    
}

- (void)setNearestUserID:(NSString *)nearestUserID {
    _nearestUserID = nearestUserID;
    
    [self showUserParametersWithAnimation:YES];
}

- (void)setOfflineMode:(OfflineMode)offlineMode {
    _offlineMode = offlineMode;
    
    if ( _offlineMode == OfflineModeNo ) {
        _contentView.alpha = 1.0f;
    } else {
        _contentView.alpha = 0.3f;
    }
    
    [self showUserParametersWithAnimation:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[ETDataModel sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(userData))];
}

@end
