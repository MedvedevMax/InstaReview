//
//  IRViewFinderLayer.h
//  InstaReview
//
//  Created by Max Medvedev on 3/28/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface IRViewFinderLayer : CALayer

@property (nonatomic) CGFloat radius;   // from 0.0 to 1.0 (to size)
@property (nonatomic) CGColorRef color;

@end
