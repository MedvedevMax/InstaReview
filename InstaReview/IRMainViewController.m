//
//  IRViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRMainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface IRMainViewController ()

@end

@implementation IRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)snapTapped
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    // checking for picked image
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imgView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
