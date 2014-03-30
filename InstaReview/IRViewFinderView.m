//
//  IRViewFinderView.m
//  InstaReview
//
//  Created by Max Medvedev on 3/28/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRViewFinderView.h"

@interface IRViewFinderView ()
@end

@implementation IRViewFinderView

@dynamic radius;

- (void)awakeFromNib
{
    self.containerLayer = [IRViewFinderLayer layer];
    self.containerLayer.frame = CGRectMake(0, 0,
                                           self.bounds.size.width, self.bounds.size.height);
    self.containerLayer.color = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:self.containerLayer];
    
    [self.containerLayer setNeedsDisplay];

    self.backgroundColor = [UIColor clearColor];
}

- (CGFloat)radius
{
    return self.containerLayer.radius;
}

- (void)setRadius:(CGFloat)radius
{
    self.containerLayer.radius = radius;
}

@end
