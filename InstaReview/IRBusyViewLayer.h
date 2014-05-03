//
//  IRBusyViewLayer.h
//  InstaReview
//
//  Created by Max Medvedev on 5/2/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface IRBusyViewLayer : CALayer

@property (nonatomic) CGFloat firstRadius;
@property (nonatomic) CGFloat secondRadius;
@property (nonatomic) CGFloat thirdRadius;

@property (nonatomic) CGColorRef color;

@end
