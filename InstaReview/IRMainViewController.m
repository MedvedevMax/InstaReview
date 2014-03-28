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
#import "IRChoosingBookViewController.h"
#import "IRBookDetailsViewController.h"

@interface IRMainViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *currentBooks;

@end

@implementation IRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    if (self.view.window) {
        self.currentBooks = nil;
    }
}

- (IBAction)snapTapped
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self performSegueWithIdentifier:@"Show Camera" sender:self];
    }
    else {
        // if camera is not available
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        picker.allowsEditing = NO;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self asynchronouslyRecognizeSingleImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CameraViewController delegate

- (void)cameraViewController:(IRCameraViewController *)viewController photoTaken:(UIImage *)photoImage
{
    [self asynchronouslyRecognizeSingleImage:photoImage];
}

-(void)cameraViewController:(IRCameraViewController *)viewController errorCapturing:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't capture" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Recognize and show books list

- (void)asynchronouslyRecognizeSingleImage:(UIImage *)image
{
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IRRecognitionSession *session = [[IRReviewsAPI sharedInstance] newSession];
        [session pushPhoto:image];
        self.currentBooks = [session recognizeAndGetReviews];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self showCurrentBooksDetails];
        });
    });
}

- (void)showCurrentBooksDetails
{
    if (!self.currentBooks) {
        // TODO: show "connection error"
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"InstaReview" message:@"Sorry, connection error :(" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else if (self.currentBooks.count == 0) {
        // TODO: show "nothing found"
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"InstaReview" message:@"No books found :(" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    else if (self.currentBooks.count == 1) {
        [self performSegueWithIdentifier:@"Show Book Details" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"Ask To Specify Book" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // remove "back" button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"Show Camera"]) {
        IRCameraViewController *cameraVC = segue.destinationViewController;
        cameraVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Ask To Specify Book"]) {
        IRChoosingBookViewController *chooseVC = segue.destinationViewController;
        chooseVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Show Book Details"]) {
        IRBookDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.currentBook = [self.currentBooks objectAtIndex:0];
    }
}

#pragma mark - IRBooksContainerDelegate

- (NSArray *)books
{
    return self.currentBooks;
}

@end
