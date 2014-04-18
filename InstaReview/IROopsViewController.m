//
//  IROopsViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 4/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IROopsViewController.h"

@interface IROopsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *errorExplanationLabel;
@end

@implementation IROopsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch (self.errorType) {
        case kOopsViewTypeNoNetwork:
            self.navigationItem.title = NSLocalizedString(@"No network", @"'no network' error");
            self.errorExplanationLabel.text = NSLocalizedString(@"The network seems to be unavailable now", @"'no network' explaration");
            break;
        case kOopsViewTypeNoBookFound:
            self.navigationItem.title = NSLocalizedString(@"No books", @"'no books' error");
            self.errorExplanationLabel.text = NSLocalizedString(@"This book wasn't found. Maybe you should try again?", @"'no books' explaration");
            break;
            
        default:
            break;
    }
}

- (IBAction)tryAgainTapped
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate tryAgainButtonTapped];
}

@end
