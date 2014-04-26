//
//  IRViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRBooksContainerDelegate.h"
#import "IROopsViewController.h"
#import "IRCameraOverlayViewController.h"

@interface IRMainViewController : UIViewController <IRCameraOverlayViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IROopsViewControllerDelegate>

@end
