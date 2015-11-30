//
//  FPCaptureSessionManager.h
//  FitnessPrototype
//
//  Created by Allan Ray Jasa on 1/7/13.
//  Copyright (c) 2013 Allan Ray Jasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface FPCaptureSessionManager : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;

@property (nonatomic, readonly) AVCaptureDevicePosition currentCameraPosition;

@property (nonatomic, readonly) BOOL WBAndExpLocked;

- (void)addVideoPreviewLayer;
- (void)addVideoInputForPosition:(AVCaptureDevicePosition)position;
- (void)addStillImageOutput;
- (void)captureStillImageWithSuccessBlock:(void(^)(NSData *imageData))successBlock;
- (void)addVideoDataOutput;

- (void)lockWBAndExp;

@end
