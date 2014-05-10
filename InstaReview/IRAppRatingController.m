//
//  IRAppRatingController.m
//  InstaReview
//
//  Created by Max Medvedev on 5/10/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRAppRatingController.h"

@implementation IRAppRatingController

#define APP_APPSTORE_URL @"http://instareview.me/appstore/"

@synthesize appLaunchAmount = _appLaunchAmount;

+ (id)sharedInstance
{
    static IRAppRatingController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[IRAppRatingController alloc] init];
    });
    return _sharedInstance;
}

- (void)showAppRatingPromptIfNeeded
{
    if ([self shouldShowAppRatingPrompt]) {
        UIAlertView *askingView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rate InstaReview", @"Rate title")
                                                             message:NSLocalizedString(@"RateMyApp", @"advice to rate app")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Rate it now!", @"rate button")
                                                   otherButtonTitles:
                                   NSLocalizedString(@"Maybe later", @"late button text"),
                                   NSLocalizedString(@"No, thanks", @"no thanks button"), nil];
        [askingView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_APPSTORE_URL]];
            [self setToNeverShowAgain];
            break;
            
        case 1:
            [self setAppLaunchAmount:0];
            break;
            
        case 2:
            [self setToNeverShowAgain];
            break;
            
        default:
            break;
    }
}

- (BOOL)shouldShowAppRatingPrompt
{
    #define LAUNCH_AMOUNT_TO_SHOW   3
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL doNotShow = [userDefaults boolForKey:@"DoNotShowAppRatingPrompt"];
    
    if (self.appLaunchAmount >= LAUNCH_AMOUNT_TO_SHOW && !doNotShow) {
        return YES;
    }
    
    return NO;
}

- (void)setToNeverShowAgain
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DoNotShowAppRatingPrompt"];
}

- (int)appLaunchAmount
{
    if (!_appLaunchAmount) {
        _appLaunchAmount = [[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchAmounts"];
    }
    
    return _appLaunchAmount;
}

- (void)setAppLaunchAmount:(int)appLaunchAmount
{
    _appLaunchAmount = appLaunchAmount;
    [[NSUserDefaults standardUserDefaults] setInteger:appLaunchAmount forKey:@"LaunchAmounts"];
}

@end
