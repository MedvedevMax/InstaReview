//
//  IRChoosingBookViewController.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRBooksContainerDelegate.h"

@interface IRChoosingBookViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<IRBooksContainerDelegate> delegate;

@end
