//
//  IRViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRMainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "IRCameraOverlayViewController.h"
#import "IRReviewsAPI.h"
#import "IRChoosingBookViewController.h"
#import "IRBookDetailsViewController.h"

@interface IRMainViewController ()
@property (nonatomic, strong) NSArray *currentBooks;

@property (weak, nonatomic) IBOutlet UIButton *snapButton;

@property (nonatomic, strong) IRCameraOverlayViewController *overlayViewController;
@end

@implementation IRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title.png"]];
    
    // Width equivalent to system default Done button's (which appears on pushed view in my case).
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithCustomView:[[UIView alloc]
                                                               initWithFrame:CGRectMake(0, 0, 50, 1)]];
    leftBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
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
    // showing camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        self.overlayViewController = [[IRCameraOverlayViewController alloc] initWithNibName:@"IRCameraOverlayViewController" bundle:nil];
        [self.overlayViewController setImagePickerController:picker];
    }
    else {
        // if camera is not available
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    picker.delegate = self;
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - ImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self asynchronouslyRecognizePhoto:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)asynchronouslyRecognizePhoto:(UIImage *)photo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.currentBooks = [[IRReviewsAPI sharedInstance] getBooksForPhoto:photo];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showCurrentBooksDetails];
        });
    });
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - Recognize and show books list

- (void)showCurrentBooksDetails
{
    if (self.currentBooks.count == 0) {
        [self performSegueWithIdentifier:@"Show Error" sender:self];
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
    
    if ([segue.identifier isEqualToString:@"Ask To Specify Book"]) {
        IRChoosingBookViewController *chooseVC = segue.destinationViewController;
        chooseVC.kind = kChoosingBookViewControllerDidYouMean;
        chooseVC.books = self.currentBooks;
    }
    else if ([segue.identifier isEqualToString:@"Show History"]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        
        IRChoosingBookViewController *chooseVC = [navigationVC.viewControllers objectAtIndex:0];
        chooseVC.kind = kChoosingBookViewControllerHistory;
        chooseVC.books = [[IRReviewsAPI sharedInstance] getAllViewedBooks];
    }
    else if ([segue.identifier isEqualToString:@"Show Book Details"]) {
        IRBookDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.currentBook = [self.currentBooks objectAtIndex:0];
    }
    else if ([segue.identifier isEqual:@"Show Error"]) {
        IROopsViewController *oopsVC = segue.destinationViewController;
        oopsVC.delegate = self;
        oopsVC.errorType = (self.currentBooks == nil) ? kOopsViewTypeNoNetwork : kOopsViewTypeNoBookFound;
    }
}

#pragma mark - IROopsViewControllerDelegate

- (void)tryAgainButtonTapped
{
    [self snapTapped];
}

@end
