//
//  ETCertificateViewController.m
//  Histo
//
//  Created by Idriss on 20/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ETCertificateViewController.h"
#import "Histogram.h"
#import "UsersData.h"
#import "SelfUserData.h"
#import "ETWatermarkView.h"
#import "ETUnitConverter.h"
#import "NSUserDefaults+Preferences.h"
#import "UIDevice+Models.h"
#import "ETDataModel.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface ETCertificateViewController ()

<
UITextFieldDelegate,
UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *backView;
@property (weak, nonatomic) IBOutlet UIView *certificateView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet ETWatermarkView *watermarkView;

@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *thicknessLabel;
@property (weak, nonatomic) IBOutlet UILabel *thickestAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *curvatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

@property (weak, nonatomic) IBOutlet Histogram *lengthHisto;
@property (weak, nonatomic) IBOutlet Histogram *girthHisto;
@property (weak, nonatomic) IBOutlet Histogram *thicknessHisto;

@property (nonatomic, strong) UsersData *usersData;
@property (nonatomic, strong) SelfUserData *selfUserData;

- (IBAction)tapBack:(UIBarButtonItem *)sender;
- (IBAction)tapShare;

@end



@implementation ETCertificateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameTextField.layer.shadowColor = [UIColor blueColor].CGColor;
    _usernameTextField.layer.shadowOpacity = 0.0f;
    _usernameTextField.layer.shadowRadius = 5.0f;
    _usernameTextField.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [self setupNotifications];
    [self setupTitle];
    [self updateViewsData];
    [self setWatermarkText];
    
    [[ETDataModel sharedInstance] addObserver:self
                                   forKeyPath:NSStringFromSelector(@selector(userData))
                                      options:0
                                      context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( [_usernameTextField.text compare:@"username" options:NSCaseInsensitiveSearch] == NSOrderedSame ) {
        [NSObject dispatchAfter:1 block:^{
            [self animateUsername];
        }];
    }
    
}

#pragma mark - Private

- (void)animateUsername {
    
    [_usernameTextField.layer removeAnimationForKey:@"shadowOpacity"];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0.0];
    anim.toValue = [NSNumber numberWithFloat:1.0];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = 5;

    [_usernameTextField.layer addAnimation:anim forKey:@"shadowOpacity"];
    _usernameTextField.layer.shadowOpacity = 0.0;
    
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)setupTitle {
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"ManHood"];
    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Exo-ExtraLight" size:17.0f] range:NSMakeRange(0, 3)];
    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Exo-ExtraBold" size:17.0f] range:NSMakeRange(3, 4)];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = title;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)updateViewsData {
    
    _lengthHisto.animated = NO;
    _girthHisto.animated = NO;
    _thicknessHisto.animated = NO;

    _lengthHisto.binColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    _girthHisto.binColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    _thicknessHisto.binColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    
    _lengthHisto.selectedWidth = 9.0f;
    _girthHisto.selectedWidth = 9.0f;
    _thicknessHisto.selectedWidth = 9.0f;
    
    _lengthHisto.bins = [self createBinsFromEdges:_usersData.lengthBins counts:_usersData.lengthCounts];
    _girthHisto.bins = [self createBinsFromEdges:_usersData.girthBins counts:_usersData.girthCounts];
    _thicknessHisto.bins = [self createBinsFromEdges:_usersData.thicknessBins counts:_usersData.thicknessCounts];
    
    _lengthHisto.secondHighlightedBinColor = _lengthLabel.textColor;
    _girthHisto.secondHighlightedBinColor = _thickestAtLabel.textColor;
    _thicknessHisto.secondHighlightedBinColor = _thicknessLabel.textColor;
    
    if ( [self shouldHideData] ) {
        
        NSString *naText = @"---";
        _lengthLabel.text = naText;
        _thicknessLabel.text = naText;
        _thickestAtLabel.text = naText;
        _curvatureLabel.text = naText;
        _dateLabel.text = naText;
        _deviceLabel.text = naText;
        
        _usernameTextField.hidden = YES;

    } else {
        ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];
        
        _lengthLabel.text = [NSString stringWithFormat:@"%0.1f %@ / %0.1f %@",
                             [_selfUserData length],
                             [ETUnitConverter nameForUnitType:ConverterUnitTypeCM],
                             [ETUnitConverter convertCMValue:[_selfUserData length] toUnit:ConverterUnitTypeINCH],
                             [ETUnitConverter nameForUnitType:ConverterUnitTypeINCH]];
        
        _thicknessLabel.text = [NSString stringWithFormat:@"%0.1f %@ / %0.1f %@",
                                [_selfUserData girth],
                                [ETUnitConverter nameForUnitType:ConverterUnitTypeCM],
                                [ETUnitConverter convertCMValue:[_selfUserData girth] toUnit:ConverterUnitTypeINCH],
                                [ETUnitConverter nameForUnitType:ConverterUnitTypeINCH]];
        
        _thickestAtLabel.text = [ETDataModel fractionForValue:[_selfUserData thickness]];
        
        _curvatureLabel.text = [NSString stringWithFormat:@"%.0f˚", floorf(_selfUserData.tipPosition.y)];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"dd MMMM yyyy"];
        
        _dateLabel.text = [formatter stringFromDate:_selfUserData.date];
        
        _deviceLabel.text = _selfUserData.device;
        
        _usernameTextField.hidden = NO;
        
        NSUInteger lengthBinIndex = [self binIndexForValue:[_selfUserData length] fromEdges:_usersData.lengthBins];
        if ( lengthBinIndex != NSNotFound ) {
            _lengthHisto.secondHighlightedBinIndex = lengthBinIndex;
        }
        
        NSUInteger girthBinIndex = [self binIndexForValue:[_selfUserData girth] fromEdges:_usersData.girthBins];
        if ( girthBinIndex != NSNotFound ) {
            _girthHisto.secondHighlightedBinIndex = girthBinIndex;
        }
        NSUInteger thicknessBinIndex = [self binIndexForValue:[_selfUserData thickness] fromEdges:_usersData.thicknessBins];
        if ( thicknessBinIndex != NSNotFound ) {
            _thicknessHisto.secondHighlightedBinIndex = thicknessBinIndex;
        }

    }
    
    [self setWatermarkText];
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

- (UIImage*)makeCertificate {
    
    CGSize imageSize = _certificateView.frame.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[_certificateView.layer presentationLayer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (void)setWatermarkText {
    
    NSString *username = ([self shouldHideData] || [[_usernameTextField.text lowercaseString] isEqualToString:@"username"]) ? @"" : _usernameTextField.text ;
    
    if ( [[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userFemale] ) {
        username = @"Example";
    }
    
    UIColor *textColor = [UIColor colorWithWhite:0.7f alpha:0.1f];
    NSString *rawText = [NSString stringWithFormat:@"ManHood%@", username];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:rawText];

    [text setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Exo-Regular" size:36.0f],
                          NSForegroundColorAttributeName: textColor}
                  range:NSMakeRange(0, 3)];
    [text setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Exo-ExtraBold" size:36.0f],
                          NSForegroundColorAttributeName: textColor}
                  range:NSMakeRange(3, 4)];
    [text setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Exo-ExtraLight" size:36.0f],
                          NSForegroundColorAttributeName: textColor}
                  range:NSMakeRange(7, username.length)];
    
    _watermarkView.text = text;
}

- (BOOL)shouldHideData {
    BOOL female = [[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userFemale];
    BOOL privacyLock = [[NSUserDefaults standardUserDefaults] privacyLock];
    
    return !_selfUserData || female || privacyLock;
}

#pragma mark - Public

- (void)setUsersData:(UsersData*)usersData selfUserData:(SelfUserData*)selfUserData {
    self.selfUserData = selfUserData;
    self.usersData = usersData;
    
    [self updateViewsData];
}

#pragma mark - Actions

- (IBAction)tapBack:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapShare {
    
    if ( [self shouldHideData] || ![[_usernameTextField.text lowercaseString] isEqualToString:@"username"] ) {
        __weak typeof(self) weakSelf = self;
        UIImageWriteToSavedPhotosAlbum([self makeCertificate], weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else {
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Username is not set"
                                                          message:@"Entering a Username is optional"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Continue", @"Enter username", nil];
        [alertView show];
    }
    
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [keyPath isEqualToString:NSStringFromSelector(@selector(userData))] ) {
        _selfUserData = [ETDataModel sharedInstance].userData;
        [self updateViewsData];
    }
}

#pragma mark - Recognizers

- (IBAction)swipeBack:(UISwipeGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Alerts

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        __weak typeof(self) weakSelf = self;
        UIImageWriteToSavedPhotosAlbum([self makeCertificate], weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else if ( buttonIndex == 1 ) {
        [_usernameTextField becomeFirstResponder];
    }
}

#pragma mark - Image completion handler

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if ( error ) {
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Failed to save the Certificate"
                                                          message:error.localizedDescription
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
    } else {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"           // Event category (required)
                                                              action:@"user_action"         // Event action (required)
                                                               label:@"certificate_saved"   // Event label
                                                               value:nil] build]];          // Event value
        
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"The Certificate Saved"
                                                          message:@"The Certificate has been saved to the device"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self setWatermarkText];
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notif {
    NSDictionary *notifData = [notif userInfo];
    
    [UIView animateWithDuration:[notifData[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         CGRect rect = _certificateView.frame;
                         rect.origin.y -= 100.0f;
                         _certificateView.frame = rect;
                     } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notif {
    NSDictionary *notifData = [notif userInfo];
    
    [UIView animateWithDuration:[notifData[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         CGRect rect = _certificateView.frame;
                         rect.origin.y += 100.0f;
                         _certificateView.frame = rect;
                     }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ETDataModel sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(userData))];
}

@end
