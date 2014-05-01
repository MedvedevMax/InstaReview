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

#import "UIView+Screenshot.h"
#import "BlurryModalSegue/UIImage+ImageEffects.h"

@interface IRMainViewController ()

@property (nonatomic, strong) NSArray *currentBooks;

@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (nonatomic, strong) IRCameraOverlayViewController *overlayViewController;
@property (nonatomic, strong) UIImageView *screenshotView;
@end

@implementation IRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title.png"]];
    
    // Hack to prevent titleView jumping
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
        self.overlayViewController.imagePickerController = picker;
        self.overlayViewController.delegate = self;
    }
    else {
        // if camera is not available
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
    }
    
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - imagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [[IRReviewsAPI sharedInstance] beginGettingBooksForPhoto:image];
    
    [self waitAndShowResults];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IRCameraOverlayViewControllerDelegate

- (void)overlayViewControllerPhotoCaptured:(UIImage *)image
{
    self.currentBooks = nil;
    [[IRReviewsAPI sharedInstance] beginGettingBooksForPhoto:image];
}

- (void)overlayViewControllerUsePhotoTapped
{
    // Taking screenshot of "overlay view"
    [self.overlayViewController.view screenshotAsyncWithCompletion:^(UIImage *image) {
        // Showing screenshot in the front of main view
        self.screenshotView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.screenshotView.image = image;

        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.view addSubview:self.screenshotView];
        
        // Dismissing "Camera View"
        [self dismissViewControllerAnimated:NO completion:^{
            
            // Showing loading view & waiting for result
            [self waitAndShowResults];
        }];
    }];
}

- (void)waitAndShowResults
{
    // Showing "Loading View"
    [self performSegueWithIdentifier:@"Show Loading" sender:self];
    
    // Waiting for books in separate thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.currentBooks = [[IRReviewsAPI sharedInstance] waitAndGetBooks];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showCurrentBooksDetails];
        });
    });
}

#pragma mark - Recognize and show books list

- (void)showCurrentBooksDetails
{
    // hiding "screenshot view"
    [self.screenshotView removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    // dismissing "Loading View"
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    // remove "back" button text
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
    else if ([segue.identifier isEqualToString:@"Show Error"]) {
        IROopsViewController *oopsVC = segue.destinationViewController;
        oopsVC.delegate = self;
        oopsVC.errorType = (self.currentBooks == nil) ? kOopsViewTypeNoNetwork : kOopsViewTypeNoBookFound;
    }
    else if ([segue.identifier isEqualToString:@"Show Loading"]) {
        UIViewController *loadingVC = segue.destinationViewController;
        UIImage *blurredImage = [self.screenshotView.image applyBlurWithRadius:40 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f] saturationDeltaFactor:1.0f maskImage:nil];
        loadingVC.view.backgroundColor = [UIColor colorWithPatternImage:blurredImage];
    }
}

#pragma mark - IROopsViewControllerDelegate

- (void)tryAgainButtonTapped
{
    [self snapTapped];
}

@end
