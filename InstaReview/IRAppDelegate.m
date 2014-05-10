//
//  IRAppDelegate.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRAppDelegate.h"
#import "IRAppRatingController.h"

#import "IRReviewsAPI.h"
#import "IRMainViewController.h"
#import "BlurryModalSegue.h"

@implementation IRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [[BlurryModalSegue appearance] setBackingImageBlurRadius:@(40)];
    [[BlurryModalSegue appearance] setBackingImageTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[IRReviewsAPI sharedInstance] saveViewedBooksHistory];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSInteger appLaunchAmounts = [[IRAppRatingController sharedInstance] appLaunchAmount];
    [[IRAppRatingController sharedInstance] setAppLaunchAmount:(appLaunchAmounts + 1)];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
