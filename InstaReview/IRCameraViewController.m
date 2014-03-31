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
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *infoTextLabel;

@property (nonatomic) float lastMotionRateValue;
@property (nonatomic) NSDate *stabilizationMoment;
@property (nonatomic) BOOL isPictureTakenForCurrentStabilization;
@property (nonatomic) BOOL isOkButtonActive;

@end

@implementation IRCameraViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initCapturing];
    [self initMotionDetection];
    
    [self setShadowOnView:self.viewFinderView withOpacity:0.7f andRadius:2.0f];
    [self setShadowOnView:self.infoTextLabel withOpacity:1.0f andRadius:4.0f];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.session stopRunning];
    self.motionManager = nil;
    self.session = nil;
    self.captureDevice = nil;
    self.deviceInput = nil;
    self.previewLayer = nil;
    self.stillImageOutput = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [CATransaction begin];
    [self.viewFinderView.containerLayer removeAllAnimations];
    [CATransaction commit];
    
    [self.motionManager stopDeviceMotionUpdates];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [super viewWillDisappear:animated];
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

- (void)setShadowOnView:(UIView *)view withOpacity:(float)opacity andRadius:(float)radius
{
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
}

#define MOTION_REFRESH_RATE 0.15f
#define MIN_ROTATION_RATE_THREASHOLD 0.1f
#define STABILIZATION_TIME_INTERVAL 2.0f

- (void)initMotionDetection
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = MOTION_REFRESH_RATE;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        float relativeRotationRate =
                                    sqrt(motion.rotationRate.x * motion.rotationRate.x
                                    + motion.rotationRate.y * motion.rotationRate.y
                                    + motion.rotationRate.z * motion.rotationRate.z) / 2.0;

        if (relativeRotationRate < MIN_ROTATION_RATE_THREASHOLD)
            relativeRotationRate = 0;
        
        if (relativeRotationRate > 1.0)
            relativeRotationRate = 1.0;
        
        [self refreshViewFinderWithMotionRate:relativeRotationRate];
    }];
    self.stabilizationMoment = [[NSDate date] dateByAddingTimeInterval:2.0];
}

- (void)refreshViewFinderWithMotionRate:(float)motionRate
{
    #define PROCESSING_LABEL_ANIMATION_DURATION 0.2f
    
    float averageMotionRate = (motionRate + self.lastMotionRateValue) / 2.0;
    
    if (self.viewFinderView.radius != averageMotionRate) {
        // animating radius
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"radius"];
        animation.duration = MOTION_REFRESH_RATE;
        animation.fromValue = [NSNumber numberWithFloat:self.viewFinderView.radius];
        animation.toValue = [NSNumber numberWithFloat:averageMotionRate];
        
        self.viewFinderView.radius = averageMotionRate;
        [self.viewFinderView.containerLayer addAnimation:animation forKey:@"radius"];
    }
    
    // catching stabilization moment
    if (self.lastMotionRateValue > 0 && motionRate == 0) {
        self.stabilizationMoment = [NSDate date];
    }
    
    self.lastMotionRateValue = motionRate;
    
    float stabilizationTime = [[NSDate date] timeIntervalSinceDate:self.stabilizationMoment];
    if (averageMotionRate == 0 &&
        stabilizationTime >= STABILIZATION_TIME_INTERVAL &&
        ![self.captureDevice isAdjustingFocus]) {
        
        // if focused & no motion for enough time
        // check if viewFinder is still white -> turn it to green/
        // then take a photo
        if (!self.isPictureTakenForCurrentStabilization) {
            [self takePhotoAndPush];
            self.isPictureTakenForCurrentStabilization = YES;
        }
    }
    else {
        // not focused or moving
        self.isPictureTakenForCurrentStabilization = NO;
    }
}

- (void)takePhotoAndPush
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
                                                       completionHandler:
     ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSData *jpegImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *takenImage = [UIImage imageWithData:jpegImageData];

            [self.delegate cameraViewController:self photoTaken:takenImage];
            [self flashAnimation];
            [self activateOkButton];
       }];
}

- (void)activateOkButton
{
    #define BUTTON_SCALE 1.3f
    #define DELAY_TIME 0.7f
    
    self.isOkButtonActive = YES;
    self.infoTextLabel.text = NSLocalizedString(@"Tap OK to get reviews", nil);
    [UIView animateWithDuration:0.2f delay:DELAY_TIME options:0 animations:^{
        self.okButton.backgroundColor = [UIColor colorWithRed:0 green:0.5f blue:0 alpha:1.0f];
    } completion:nil];
    
    CABasicAnimation *throbAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    throbAnimation.autoreverses = YES;
    throbAnimation.duration = 0.1f;
    throbAnimation.beginTime = CACurrentMediaTime() + DELAY_TIME;
    throbAnimation.toValue = [NSValue valueWithCATransform3D:
                              CATransform3DMakeScale(BUTTON_SCALE, BUTTON_SCALE, 1.0f)];
    [self.okButton.layer addAnimation:throbAnimation forKey:@"transform"];
}

- (void)flashAnimation
{
    UIView *whiteView = [[UIView alloc] initWithFrame:self.view.frame];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    [UIView animateWithDuration:0.5f animations:^{
        whiteView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [whiteView removeFromSuperview];
    }];
}

- (void)shakeView:(UIView*)view
{
    #define SHAKING_AMPLITUDE 6.0f
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.05;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(view.center.x - SHAKING_AMPLITUDE,
                                                                view.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(view.center.x + SHAKING_AMPLITUDE,
                                                              view.center.y)];
    
    [view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - IBActions

- (IBAction)okButtonTapped
{
    if (self.isOkButtonActive) {
        [self.delegate cameraViewControllerOkTapped:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self shakeView:self.viewFinderView];
    }
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
