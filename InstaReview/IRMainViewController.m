//
//  IRViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRMainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "IRReviewsAPI.h"

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
    UIImage *snap = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self asynchronouslyRecognizeImage:snap];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)asynchronouslyRecognizeImage:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *bookName = [[IRReviewsAPI sharedInstance] getBookNameForCover:image];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Recognized" message:bookName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        });
    });
}

@end
