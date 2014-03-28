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

- (void)turnToGreen
{
    UIColor *lightGreen = [[UIColor alloc] initWithRed:0.4 green:1.0 blue:0.4 alpha:1.0];
    if (self.containerLayer.color != [lightGreen CGColor]) {
        [self animateToColor:lightGreen];
    }
}

- (void)turnToWhite
{
    if (self.containerLayer.color != [[UIColor whiteColor] CGColor]) {
        [self animateToColor:[UIColor whiteColor]];
    }
}

- (void)animateToColor:(UIColor *)color
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"color"];
    animation.duration = 0.2f;
    animation.fromValue = (id) self.containerLayer.color;
    animation.toValue = (id) color.CGColor;
    
    self.containerLayer.color = color.CGColor;
    [self.containerLayer addAnimation:animation forKey:@"color"];
}

@end
