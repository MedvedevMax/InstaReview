//
//  IROopsViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 4/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kOopsViewTypeNoNetwork = 0,
    kOopsViewTypeNoBookFound = 1
} IROopsViewErrorType;

@protocol IROopsViewControllerDelegate <NSObject>

- (void)tryAgainButtonTapped;

@end

@interface IROopsViewController : UIViewController

@property (nonatomic) IROopsViewErrorType errorType;

@property (nonatomic, weak) id<IROopsViewControllerDelegate> delegate;

@end
