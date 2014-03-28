//
//  IRViewFinderView.h
//  InstaReview
//
//  Created by Max Medvedev on 3/28/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRViewFinderLayer.h"

@interface IRViewFinderView : UIView

@property (nonatomic) CGFloat radius;   // from 0.0 to 1.0 (to size)
@property (nonatomic, strong) IRViewFinderLayer *containerLayer;

- (void)turnToWhite;
- (void)turnToGreen;

@end
