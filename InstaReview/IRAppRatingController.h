//
//  IRAppRatingController.h
//  InstaReview
//
//  Created by Max Medvedev on 5/10/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRAppRatingController : NSObject <UIAlertViewDelegate>

+ (id)sharedInstance;

@property (nonatomic) long appLaunchAmount;
- (void)showAppRatingPromptIfNeeded;

@end
