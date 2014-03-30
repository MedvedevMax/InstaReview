//
//  IRCameraViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 3/27/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRCameraViewController;
    
@protocol IRCameraViewControllerDelegate <NSObject>

- (void)cameraViewControllerOkTapped:(IRCameraViewController*)viewController;
- (void)cameraViewController:(IRCameraViewController*)viewController photoTaken:(UIImage*)image;
- (void)cameraViewController:(IRCameraViewController*)viewController errorCapturing:(NSError*)error;

@end

@interface IRCameraViewController : UIViewController

@property (nonatomic, assign) id<IRCameraViewControllerDelegate> delegate;

@end
