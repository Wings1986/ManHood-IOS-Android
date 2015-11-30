//
//  FPCaptureSessionManager.m
//  FitnessPrototype
//
//  Created by Allan Ray Jasa on 1/7/13.
//  Copyright (c) 2013 Allan Ray Jasa. All rights reserved.
//

#import "FPCaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@interface FPCaptureSessionManager()

@end

@implementation FPCaptureSessionManager

- (id)init
{
    if(self = [super init]){
        _captureSession = [[AVCaptureSession alloc] init];
        _currentCameraPosition = AVCaptureDevicePositionUnspecified;
    }
    
    return self;
}

- (void)addVideoPreviewLayer
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)addVideoInputForPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devices];
    
    _currentCameraPosition = position;
    
    for(AVCaptureDevice *device in devices){
        if([device hasMediaType:AVMediaTypeVideo] && [device position] == position){
            
            // default the camera to the front cam
            _videoDevice = device;
            break;
        }
    }
    
    if(_videoDevice){
        
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
        
        if (!error) {
            if([self.captureSession canAddInput:videoIn]){
                [self.captureSession addInput:videoIn];
            } else{
                NSLog(@"Could not add video input");
            }
        } else {
            NSLog(@"Could not create video input");
        }
        
        if([_videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] && [_videoDevice lockForConfiguration:&error]){
            CGPoint exposurePoint = CGPointMake(0.5f, 0.5f);
            [_videoDevice setExposurePointOfInterest:exposurePoint];
            [_videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            NSLog(@"Continuous Auto Exposure set");
            [_videoDevice unlockForConfiguration];
        }
        
        if ([_videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] && [_videoDevice lockForConfiguration:&error]) {
            [_videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            NSLog(@"Continuous White Balance set");
            [_videoDevice unlockForConfiguration];
        }
    }
}

#define CAPTURE_FRAMES_PER_SECOND 20

- (void)addVideoDataOutput
{
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    self.videoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in self.videoDataOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }

    [self.captureSession addOutput:self.videoDataOutput];


}

- (void)addStillImageOutput
{
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    self.stillImageOutput.outputSettings = outputSettings;
    
    [self.captureSession addOutput:self.stillImageOutput];
    
    //Make the image with resolution the highest for that camera
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }
}

- (void)captureStillImageWithSuccessBlock:(void(^)(NSData *imageData))successBlock
{
    
    if ( successBlock == nil ) {
        return;
    }
    
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             //NSLog(@"exifAttachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             successBlock(imageData);
         });
     }];
}
 

- (void)lockWBAndExp {
    
    if ( _WBAndExpLocked ) {
        return;
    }
    
    NSError *error;
    
    if([_videoDevice isExposureModeSupported:AVCaptureExposureModeLocked] && [_videoDevice lockForConfiguration:&error]){
        [_videoDevice setExposureMode:AVCaptureExposureModeLocked];
        NSLog(@"Exposure locked");
        [_videoDevice unlockForConfiguration];
    }
    
    if ([_videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] && [_videoDevice lockForConfiguration:&error]) {
        [_videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        NSLog(@"White Balance locked");
        [_videoDevice unlockForConfiguration];
    }
    
    if (error) {
        NSLog(@"Can't set WB and exposure : %@", error);
    } else {
        _WBAndExpLocked = YES;
    }
}

@end
