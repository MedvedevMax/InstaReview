//
//  IRCameraOverlayViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 4/26/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRCameraOverlayViewController.h"

#define IS_4_INCH_DISPLAY ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface IRCameraOverlayViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flashModeLabel;
@property (nonatomic) UIImagePickerControllerCameraFlashMode cameraFlashMode;

@property (strong, nonatomic) IBOutlet UIView *useRetakeView;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;

@end

@implementation IRCameraOverlayViewController

@synthesize imagePickerController = _imagePickerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - Main view

- (IBAction)shootButtonTapped
{
    [self.imagePickerController takePicture];
}

- (IBAction)flashModeButtonTapped:(UIButton *)sender
{
    #define TEXT_TRANSITION_DURATION 0.5f
    
    if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        [sender setImage:[UIImage imageNamed:@"FlashButton-on.png"] forState:UIControlStateNormal];

        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [UIView transitionWithView:self.flashModeLabel
                          duration:TEXT_TRANSITION_DURATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
            self.flashModeLabel.text = NSLocalizedString(@"on", @"flash mode on");
        } completion:nil];
    }
    
    else if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn) {
        [sender setImage:[UIImage imageNamed:@"FlashButton-off.png"] forState:UIControlStateNormal];
        
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [UIView transitionWithView:self.flashModeLabel
                          duration:TEXT_TRANSITION_DURATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.flashModeLabel.text = NSLocalizedString(@"off", @"flash mode off");
                        } completion:nil];
    }
    
    else if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff)
    {
        [sender setImage:[UIImage imageNamed:@"FlashButton-auto.png"] forState:UIControlStateNormal];

        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        [UIView transitionWithView:self.flashModeLabel
                          duration:TEXT_TRANSITION_DURATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.flashModeLabel.text = NSLocalizedString(@"auto", @"flash mode auto");
                        } completion:nil];
    }
}

- (IBAction)dismissButtonTapped
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - Use/Retake Image View

- (IBAction)usePhotoButtonTapped
{
    [self.delegate overlayViewControllerUsePhotoTapped];
}

- (IBAction)retakePhotoButtonTapped
{
    [UIView transitionWithView:self.view
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        [self.useRetakeView removeFromSuperview];

                    } completion:nil];
}

- (void)setImagePickerController:(UIImagePickerController *)imagePickerController
{
    if (_imagePickerController) {
        if (_imagePickerController.cameraOverlayView == self.view) {
            _imagePickerController.cameraOverlayView = nil;
        }
        if (_imagePickerController.delegate == self) {
            _imagePickerController.delegate = nil;
        }
    }
    
    _imagePickerController = imagePickerController;
    imagePickerController.cameraOverlayView = self.view;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.delegate = self;
    
    if (IS_4_INCH_DISPLAY) {
        self.imagePickerController.cameraViewTransform =
            CGAffineTransformMakeTranslation(0.0, 71.0);
    }
}

#pragma mark - ImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    // make image portrait if not
    image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    
    [self.delegate overlayViewControllerPhotoCaptured:image];
    
    // confirm if photo is OK
    self.useRetakeView.frame = self.view.frame;
    self.capturedImageView.image = image;
    
    [UIView transitionWithView:self.view
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        [self.view addSubview:self.useRetakeView];
                        
                    } completion:nil];
}

- (void)animateShootEffect
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
