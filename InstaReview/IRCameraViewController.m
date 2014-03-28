//
//  IRCameraViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/27/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRCameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "IRViewFinderView.h"

@interface IRCameraViewController ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet IRViewFinderView *viewFinderView;

@property (nonatomic) float lastMotionRateValue;

@end

@implementation IRCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initCapturing];
    [self initMotionDetection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)initCapturing
{
    // prepare session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // prepare input device
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([self.captureDevice lockForConfiguration:&error]) {
            self.captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [self.captureDevice unlockForConfiguration];
        }
        
        if (error) {
            NSLog(@"Unpredicted error while configuring input device: %@", error);
        }
    }
    
    NSError *error;
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (error) {
        [self.delegate cameraViewController:self errorCapturing:error];
        return;
    }
    
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    
    // prepare output device
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    // initializing preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = self.view.layer;
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:rootLayer.bounds];
    [rootLayer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
}

- (void)initMotionDetection
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.15f;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        float relativeRotationRate =
                                    sqrt(motion.rotationRate.x * motion.rotationRate.x
                                    + motion.rotationRate.y * motion.rotationRate.y
                                    + motion.rotationRate.z * motion.rotationRate.z) / 2.0;

        if (relativeRotationRate < 0.05)
            relativeRotationRate = 0;
        
        if (relativeRotationRate > 1.0)
            relativeRotationRate = 1.0;
        
        [self deviceMovementsDetected:relativeRotationRate];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.session stopRunning];
    
    self.session = nil;
    self.captureDevice = nil;
    self.deviceInput = nil;
    self.previewLayer = nil;
    self.stillImageOutput = nil;
    
    [self.motionManager stopAccelerometerUpdates];
    self.motionManager = nil;
}

- (void)deviceMovementsDetected:(float)motionRate
{
    float averageMotionRate = (motionRate + self.lastMotionRateValue) / 2.0;
    
    if (self.viewFinderView.radius != averageMotionRate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"radius"];
        animation.duration = 0.15f;
        animation.fromValue = [NSNumber numberWithFloat:self.viewFinderView.radius];
        animation.toValue = [NSNumber numberWithFloat:averageMotionRate];
        
        self.viewFinderView.radius = averageMotionRate;
        [self.viewFinderView.containerLayer addAnimation:animation forKey:@"radius"];
    }
    
    self.lastMotionRateValue = motionRate;
}

- (IBAction)snapButtonTapped
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
           NSData *jpegImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
           UIImage *takenImage = [UIImage imageWithData:jpegImageData];
           
           [self.delegate cameraViewController:self photoTaken:takenImage];
       }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)flashOnButtonTapped
{
    if ([self.captureDevice hasTorch]) {
        NSError *error;
        if ([self.captureDevice lockForConfiguration:&error]) {
            if (!self.captureDevice.torchActive) {
                self.captureDevice.torchMode = AVCaptureTorchModeOn;
            }
            else {
                self.captureDevice.torchMode = AVCaptureTorchModeOff;
            }
        }
        
        if (error) {
            NSLog(@"Unpredicted error while configuring input device: %@", error);
        }
        
        [self.captureDevice unlockForConfiguration];
    }
}

- (IBAction)dismissButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
