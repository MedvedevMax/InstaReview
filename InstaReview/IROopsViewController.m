//
//  IROopsViewController.m
//  InstaReview
//
//  Created by Max Medvedev on 4/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IROopsViewController.h"

@interface IROopsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *errorExplanationImage;
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
            self.errorExplanationImage.image = [UIImage imageNamed:@"NoNetwork.png"];
            break;
        case kOopsViewTypeNoBookFound:
            self.navigationItem.title = NSLocalizedString(@"No books", @"'no books' error");
            self.errorExplanationLabel.text = NSLocalizedString(@"This book wasn't found. Maybe you should try again?", @"'no books' explaration");
            self.errorExplanationImage.image = [UIImage imageNamed:@"SadSmile.png"];
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]];
}

- (IBAction)tryAgainTapped
{
    [self.navigationController popViewControllerAnimated:YES];

    NSObject<IROopsViewControllerDelegate> *nsObjectTypedDelegate = self.delegate;
    [nsObjectTypedDelegate performSelector:@selector(tryAgainButtonTapped) withObject:nil afterDelay:0.2];
}

@end
