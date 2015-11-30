//
//  ETCameraViewController.m
//  Histo
//
//  Created by Viktor Gubriienko on 12.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ETCameraViewController.h"
#import "FPCaptureSessionManager.h"
#import "ETImagePopupView.h"
#import "ETFlow.h"
#import "ETDataModel.h"
#import "ETRequestManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface ETCameraViewController ()

<
AVCaptureVideoDataOutputSampleBufferDelegate,
UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *cameraContentView;
@property (nonatomic, strong) FPCaptureSessionManager *captureManager;
@property (nonatomic, strong) dispatch_queue_t processqueue;

@property (weak, nonatomic) IBOutlet UILabel *frontLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomPanelView;
@property (weak, nonatomic) IBOutlet UIImageView *frontCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *frontTickImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sideTickImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTitle;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

- (IBAction)tapBack:(UIBarButtonItem *)sender;
- (IBAction)tapInfo:(UIBarButtonItem *)sender;
- (IBAction)tapBottomButton;

@end

@implementation ETCameraViewController  {
    UIButton *_cameraButton;
    ETImagePopupView *_popupView;
    UIImageView *_overlayImageView;
    UIImageView *_adjImageView;

    BOOL _initialAppear;
}


#pragma mark - VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    _cameraContentView.layer.borderColor = [UIColor whiteColor].CGColor;
    _cameraContentView.layer.borderWidth = 1.0f;
    
    _initialAppear = YES;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( _initialAppear ) {
        [self runNextFlowStep];
        _initialAppear = NO;
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self hideCameraButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)runNextFlowStep {
    ETFlowStep *step = [self.flow moveToNextStep];
    
    if ([step.type isEqualToString:@"Camera"]) {
        [self hideAdjImageView];
        [self hideAdjOverlay];
        [self showCameraButton];
        [self startCamera];
        [self showHintImage];
    } else if ([step.type isEqualToString:@"Adj"]) {
        [self hideCameraButton];
        [self stopCamera];
        [self showAdjImageView];
        [self showAdjOverlay];
        [self showHintImage];
    } else {
        [self hideCameraButton];
        [self stopCamera];
        [self hideAdjImageView];
        [self hideAdjOverlay];
        [self hideHintImage];
    }
    
    [self setupContent];
    
    if ( step == nil ) { // Done everything
        [self analyzePhotos];
    }
}

- (void)analyzePhotos {
    /* save to documents for test
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSData *data = UIImageJPEGRepresentation((UIImage*)[(ETFlowStep*)(_flow.steps[0]) data], 0.8);
    [data writeToFile:[dir stringByAppendingPathComponent:@"orig.jpg"] atomically:YES];
    [[_flow.steps[2] data] writeToFile:[dir stringByAppendingPathComponent:@"adj.jpg"] atomically:YES];
    /**/
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"           // Event category (required)
                                                          action:@"user_action"         // Event action (required)
                                                           label:@"analyze_photos"      // Event label
                                                           value:nil] build]];          // Event value
    
    [[ETDataModel sharedInstance] analyzePhotosWithFlow:_flow finishBlock:^(BOOL success, NSError *error) {
        __weak typeof(self) weakSelf = self;
        if ( success ) {
            [UIAlertView showWithTitle:@"Success!"
                               message:@"See your data with the 'Your Results'-button, or in the certificate. You can hide/unhide the data in the Settings."
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil
                              tapBlock:nil];
            [self goBack];
        } else {
            if (error.code == ServerErrorCodeMeasurementError) {
                [UIAlertView showWithTitle:@"Something wasn't right"
                                   message:error.localizedDescription
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@[@"Retake"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Retake"] ) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          [strongSelf->_flow reset];
                                          [strongSelf runNextFlowStep];
                                      } else {
                                          [weakSelf goBack];
                                      }
                                  }];
            } else {
                [UIAlertView showWithTitle:@"Something wasn't right"
                                   message:error.localizedDescription
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@[@"Retry"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Retry"] ) {
                                          [weakSelf analyzePhotos];
                                      } else {
                                          [weakSelf goBack];
                                      }
                                  }];
            }
        }
    }];
}

- (void)showCameraButton {
    if ( _cameraButton ) {
        return;
    }
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraButton.frame = self.view.bounds;
    [_cameraButton addTarget:self action:@selector(tapCameraButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
}

- (void)hideCameraButton {
    [_cameraButton removeFromSuperview];
    _cameraButton = nil;
}

- (void)startCamera {
    if ( self.captureManager == nil ) {
        self.captureManager = [[FPCaptureSessionManager alloc] init];
        [self.captureManager addVideoInputForPosition:AVCaptureDevicePositionBack];
        [self.captureManager addVideoPreviewLayer];
        [self.captureManager addStillImageOutput];
        
        self.processqueue = dispatch_queue_create("process queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t videoQueue = dispatch_queue_create("video queue", DISPATCH_QUEUE_SERIAL);
        [self.captureManager.videoDataOutput setSampleBufferDelegate:self queue:videoQueue];
        
        CGRect layerRect = _cameraContentView.bounds;
        self.captureManager.previewLayer.frame = layerRect;
        self.captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect));
        self.captureManager.previewLayer.transform = CATransform3DMakeScale(3.0f, 3.0f, 1.0f);
        [_cameraContentView.layer insertSublayer:self.captureManager.previewLayer atIndex:0];
        
        [self.captureManager.captureSession startRunning];
    }
    

}

- (void)stopCamera {
    [self.captureManager.previewLayer removeFromSuperlayer];
    self.captureManager = nil;
    self.processqueue = nil;
}

- (void)showHintImage {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHintImageAnimated) object:nil];
    
    if ( _popupView == nil ) {
        _popupView = [ETImagePopupView loadViewFromXIB];
        _popupView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        [_popupView.button addTarget:self action:@selector(hideHintImageAnimated) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_popupView];
    }
    
    _popupView.imageView.image = [UIImage imageNamed:_flow.currentStep.options[@"HintImage"]];
    _popupView.titleLabel.text = _flow.currentStep.options[@"HintTitle"];

    _popupView.alpha = 0.0f;
    _popupView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _popupView.alpha = 1.0f;
                         _popupView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         [self performSelector:@selector(hideHintImageAnimated) withObject:nil afterDelay:5.0];
                     }];
}

- (void)hideHintImageAnimated {
    [UIView animateWithDuration:0.3
                     animations:^{
                         _popupView.alpha = 0.1f;
                         _popupView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                     } completion:^(BOOL finished) {
                         if ( finished ) {
                             [self hideHintImage];
                         }
                     }];
}

- (void)hideHintImage {
    [_popupView removeFromSuperview];
    _popupView = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHintImageAnimated) object:nil];
}

- (void)showAdjOverlay {
    
    if ( _overlayImageView == nil ) {
        _overlayImageView = [[UIImageView alloc] initWithFrame:_cameraContentView.bounds];
        _overlayImageView.frame = _cameraContentView.bounds;
        _overlayImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_cameraContentView insertSubview:_overlayImageView atIndex:1];
    }
    
    _overlayImageView.image = [UIImage imageNamed:_flow.currentStep.options[@"OverlayImage"]];
}

- (void)hideAdjOverlay {
    [_overlayImageView removeFromSuperview];
    _overlayImageView = nil;
}

- (void)showAdjImageView {
    if ( _adjImageView == nil ) {
        _adjImageView = [[UIImageView alloc] init];
        _adjImageView.contentMode = UIViewContentModeCenter;
        [_cameraContentView insertSubview:_adjImageView atIndex:0];
        
        [self setupRecognizers];
    }
    
    _adjImageView.image = [self.flow stepWithID:self.flow.currentStep.options[@"ImageDataStepID"]].data;
    _adjImageView.bounds = CGRectMake(0.0f, 0.0f, _adjImageView.image.size.width, _adjImageView.image.size.height);
    _adjImageView.center = CGPointMake(CGRectGetMidX(_cameraContentView.bounds), CGRectGetMidY(_cameraContentView.bounds));
    
    CGFloat xScale = self.view.size.width / _adjImageView.image.size.width;
    CGFloat yScale = self.view.size.height / _adjImageView.image.size.height;
    CGFloat scaleToApply = xScale > yScale ? xScale : yScale;
    scaleToApply *= 3.0f; // Default 300%
    _adjImageView.transform = CGAffineTransformMakeScale(scaleToApply, scaleToApply);
    
}

- (void)hideAdjImageView {
    [_adjImageView removeFromSuperview];
    _adjImageView = nil;
}

- (void)setupRecognizers {
    UIPanGestureRecognizer *moveImageRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(moveImage:)];
    
    UIPinchGestureRecognizer *scaleImageRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(scaleImage:)];

    
    [_cameraContentView addGestureRecognizer:moveImageRecognizer];
    [_cameraContentView addGestureRecognizer:scaleImageRecognizer];
}

- (UIImage*)cropedImageByViewBorders {

    CGPoint topLeftImagePoint = [_cameraContentView convertPoint:CGPointZero toView:_adjImageView];
    CGPoint bottomRightImagePoint = [_cameraContentView convertPoint:CGPointMake(_cameraContentView.bounds.size.width,
                                                                                 _cameraContentView.bounds.size.height)
                                                              toView:_adjImageView];
    
    CGSize resultSize = CGSizeMake(bottomRightImagePoint.x - topLeftImagePoint.x, bottomRightImagePoint.y - topLeftImagePoint.y) ;
    CGRect drawRect = CGRectMake(-topLeftImagePoint.x, -topLeftImagePoint.y, _adjImageView.image.size.width, _adjImageView.image.size.height);

    UIGraphicsBeginImageContext(resultSize);
    
    [_adjImageView.image drawInRect:drawRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    CGSize cropSize = CGSizeMake(750.0f, 750.0f);
    UIGraphicsBeginImageContext(cropSize);
    
    [newImage drawInRect:CGRectMake(0.0f, 0.0f, cropSize.width, cropSize.height)];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blinkPhoto {
    UIView *blinkView = [[UIView alloc] initWithFrame:_cameraContentView.bounds];
    blinkView.backgroundColor = [UIColor whiteColor];
    [_cameraContentView addSubview:blinkView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         blinkView.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [blinkView removeFromSuperview];
                     }];
}

- (void)setupContent {
    if ([_flow.currentStep.type isEqualToString:@"Camera"] ) {
        self.title = @"CAMERA";
        _bottomTitle.text = @"Tap to take picture";
        _bottomPanelView.hidden = NO;
        _bottomButton.hidden = YES;
        if ([_flow.currentStep.options[@"Label"] isEqualToString:@"Front"] ) {
            _frontCheckImageView.hidden = YES;
            _frontLabel.hidden = NO;
            _frontTickImageView.hidden = NO;
            _sideTickImageView.hidden = YES;
        } else if ([_flow.currentStep.options[@"Label"] isEqualToString:@"Side"] ) {
            _frontCheckImageView.hidden = NO;
            _frontLabel.hidden = YES;
            _frontTickImageView.hidden = YES;
            _sideTickImageView.hidden = NO;
        }
    } else if ( [_flow.currentStep.type isEqualToString:@"Adj"] ) {
        _bottomTitle.text = @"Move and size image to fit the iPhone size";
        _bottomPanelView.hidden = YES;
        _bottomButton.hidden = NO;
        if ([_flow.currentStep.options[@"Label"] isEqualToString:@"Front"] ) {
            self.title = @"FRONT SHOT";
            [_bottomButton setTitle:@"Next" forState:UIControlStateNormal];
        } else if ([_flow.currentStep.options[@"Label"] isEqualToString:@"Side"] ) {
            self.title = @"SIDE SHOT";
            [_bottomButton setTitle:@"Analyze" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UIGestureRecognizers

- (void)moveImage:(UIPanGestureRecognizer *)moveRecognizer {
    
    CGPoint translationInView = [moveRecognizer translationInView:_adjImageView];
    if ( [self isTranslationMoreThanAllowed:translationInView] ) {
        _adjImageView.transform = CGAffineTransformTranslate(_adjImageView.transform,
                                                             translationInView.x,
                                                             translationInView.y);
    }
    
    [moveRecognizer setTranslation:CGPointZero inView:_adjImageView];
}


- (void)scaleImage:(UIPinchGestureRecognizer *)sender {
    
    if ([sender numberOfTouches] < 2)
        return;
    
    static CGFloat lastScale;
    static CGPoint lastPoint;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        lastPoint = [sender locationInView:_adjImageView];
    }
    
    // Scale
    CGFloat scale = 1.0 - (lastScale - sender.scale);
    
    if ( [self isScaleExceedsLimit:scale] ) {
        [_adjImageView.layer setAffineTransform:
         CGAffineTransformScale([_adjImageView.layer affineTransform],
                                scale,
                                scale)];
        lastScale = sender.scale;
        
        
        // Translate
        CGPoint point = [sender locationInView:_adjImageView];
        _adjImageView.transform = CGAffineTransformTranslate([_adjImageView.layer affineTransform],
                                                             point.x - lastPoint.x,
                                                             point.y - lastPoint.y);
        lastPoint = [sender locationInView:_adjImageView];
        
    }
    
}

#pragma mark - Transform Constraints

- (BOOL)isTranslationMoreThanAllowed:(CGPoint)incrementTranslation {
    CGAffineTransform imageTransform = _adjImageView.transform;
    
    //apply to transform translation
    imageTransform = CGAffineTransformTranslate(imageTransform, incrementTranslation.x, incrementTranslation.y);
    
    CGRect newFrame = [_adjImageView frameAfterTransform:imageTransform];

    return    newFrame.origin.x <= 0.0f
           && newFrame.origin.y <= 0.0f
           && ( newFrame.size.width - self.view.frame.size.width > fabsf(newFrame.origin.x) )
           && ( newFrame.size.height - self.view.frame.size.height > fabsf(newFrame.origin.y) );
}

- (BOOL)isScaleExceedsLimit:(CGFloat)scaleFactor {
    CGAffineTransform imageTransform = _adjImageView.transform;
    
    //apply scale
    imageTransform = CGAffineTransformScale(imageTransform, scaleFactor, scaleFactor);
    
    CGRect newFrame = [_adjImageView frameAfterTransform:imageTransform];
    
    return    newFrame.origin.x <= 0.0f
           && newFrame.origin.y <= 0.0f
           && ( newFrame.size.width - self.view.frame.size.width > fabsf(newFrame.origin.x) )
           && ( newFrame.size.height - self.view.frame.size.height > fabsf(newFrame.origin.y) );
}

#pragma mark - Actions

- (void)tapCameraButton {
    [self blinkPhoto];
    [self.captureManager captureStillImageWithSuccessBlock:^(NSData *imageData) {
        self.flow.currentStep.data = [UIImage imageWithData:imageData];
        [self runNextFlowStep];
    }];
}

- (IBAction)tapBack:(UIBarButtonItem *)sender {
    
    if ([_flow.currentStep.ID isEqualToString:@"FirstShot"]) {
        [self goBack];
    } else {
        [_flow reset];
        [self runNextFlowStep];
    }

}

- (IBAction)tapInfo:(UIBarButtonItem *)sender {
    [self showHintImage];
}

- (IBAction)tapBottomButton {
    if ( [self.flow.currentStep.type isEqualToString:@"Adj"] ) {
        UIImage *image = [self cropedImageByViewBorders];
        self.flow.currentStep.data = UIImageJPEGRepresentation(image, 0.8);
    }
    [self runNextFlowStep];
}

#pragma mark - Dealloc

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
