//
//  IRChoosingBookViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRBooksContainerDelegate.h"

typedef enum {
    kChoosingBookViewControllerDidYouMean = 0,
    kChoosingBookViewControllerHistory = 1
} IRChoosingBookViewControllerKind;

@interface IRChoosingBookViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) IRChoosingBookViewControllerKind kind;
@property (nonatomic, strong) NSArray *books;

@end
