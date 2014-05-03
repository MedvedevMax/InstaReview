//
//  IRBusyView.h
//  InstaReview
//
//  Created by Max Medvedev on 5/2/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRBusyView : UIView

@property (nonatomic, retain) UIColor *color;

- (void)startAnimation;

@end
