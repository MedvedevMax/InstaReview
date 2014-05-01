//
//  IRCameraOverlayViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 4/26/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRCameraOverlayViewControllerDelegate <NSObject>

- (void)overlayViewControllerPhotoCaptured:(UIImage *)image;
- (void)overlayViewControllerUsePhotoTapped;

@end

@interface IRCameraOverlayViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *imagePickerController;

@property (nonatomic, weak) id<IRCameraOverlayViewControllerDelegate> delegate;

@end
