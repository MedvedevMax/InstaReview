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
}

- (IBAction)shootButtonTapped
{
    [self.imagePickerController takePicture];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (IBAction)flashModeButtonTapped:(UIButton *)sender
{
    if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        [sender setImage:[UIImage imageNamed:@"FlashButton-on.png"] forState:UIControlStateNormal];

        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [UIView transitionWithView:self.flashModeLabel
                          duration:0.5f
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
                          duration:0.5f
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
                          duration:0.5f
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

- (void)setImagePickerController:(UIImagePickerController *)imagePickerController
{
    if (_imagePickerController) {
        if (_imagePickerController.cameraOverlayView == self.view) {
            _imagePickerController.cameraOverlayView = nil;
        }
    }
    
    _imagePickerController = imagePickerController;
    imagePickerController.cameraOverlayView = self.view;
    imagePickerController.showsCameraControls = NO;
    
    if (IS_4_INCH_DISPLAY) {
        self.imagePickerController.cameraViewTransform =
            CGAffineTransformMakeTranslation(0.0, 71.0);
    }
}

@end
