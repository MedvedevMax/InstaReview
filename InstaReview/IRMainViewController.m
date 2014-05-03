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
#import "IRBusyView.h"
#import "IRViewFinderView.h"

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
    
    [self showLoadingViewAndWaitForResults];
}

#pragma mark - IRCameraOverlayViewControllerDelegate

- (void)overlayViewControllerPhotoCaptured:(UIImage *)image
{
    self.currentBooks = nil;
    [[IRReviewsAPI sharedInstance] beginGettingBooksForPhoto:image];
}

- (void)overlayViewControllerUsePhotoTapped
{
    [self showLoadingViewAndWaitForResults];
}

- (void)showLoadingViewAndWaitForResults
{
    // Taking screenshot of current view
    [self.view screenshotAsyncWithCompletion:^(UIImage *image) {
        // Showing screenshot in the front of main view
        
        self.screenshotView = [[UIImageView alloc] initWithFrame:self.view.frame];
        UIImage *blurryImage = [image applyBlurWithRadius:30 tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4f] saturationDeltaFactor:1.0f maskImage:nil];
        self.screenshotView.image = blurryImage;

        #define ACTIVITY_VIEW_Y_POSITION 0.66
        #define ACTIVITY_VIEW_WIDTH     190
        #define ACTIVITY_VIEW_HEIGHT    65
        
        float busyViewYPos = self.view.bounds.size.height * ACTIVITY_VIEW_Y_POSITION - ACTIVITY_VIEW_HEIGHT / 2;
        IRBusyView *activityView = [[IRBusyView alloc] initWithFrame:CGRectMake((320 - ACTIVITY_VIEW_WIDTH) / 2, busyViewYPos, ACTIVITY_VIEW_WIDTH, ACTIVITY_VIEW_HEIGHT)];
        activityView.color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient_orange.png"]];
        [self.screenshotView addSubview:activityView];
        
        // Dismissing "Camera View"
        [self dismissViewControllerAnimated:YES completion:^{
            
            // Showing blured screenshot
            [UIView transitionWithView:self.view
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.view addSubview:self.screenshotView];
                            } completion:^(BOOL finished) {
                                [activityView startAnimation];
                            }];
            
            // Showing loading view & waiting for result
            [self waitAndShowResults];
        }];
    }];
}

- (void)waitAndShowResults
{
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
    // Hiding blured screenshot
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.screenshotView removeFromSuperview];
                    } completion:nil];
    
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
}

#pragma mark - IROopsViewControllerDelegate

- (void)tryAgainButtonTapped
{
    [self snapTapped];
}

@end
