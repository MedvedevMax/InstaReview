//
//  IRViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRBooksContainerDelegate.h"
#import "IRCameraViewController.h"

@interface IRMainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, IRCameraViewControllerDelegate, IRBooksContainerDelegate>

@end
