//
//  IRBusyView.m
//  InstaReview
//
//  Created by Max Medvedev on 5/2/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBusyView.h"
#import "IRBusyViewLayer.h"

@interface IRBusyView ()
@property (nonatomic, retain) IRBusyViewLayer *containerLayer;
@end

@implementation IRBusyView

@dynamic color;

- (id)init
{
    self = [super init];
    if (self) {
        [self initializeLayer];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLayer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeLayer];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self initializeLayer];
    [self startAnimation];
}

- (void)initializeLayer
{
    self.backgroundColor = [UIColor clearColor];
    
    self.containerLayer = [IRBusyViewLayer layer];
    self.containerLayer.color = [[UIColor blackColor] CGColor];
    self.containerLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.containerLayer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerLayer.shadowOffset = CGSizeMake(0, 1);
    self.containerLayer.shadowOpacity = 0.5f;
    self.containerLayer.shadowRadius = 1;
        
    [self.layer addSublayer:self.containerLayer];
    [self.containerLayer setNeedsDisplay];
}

- (void)startAnimation
{
    self.containerLayer.firstRadius = 0;
    self.containerLayer.secondRadius = 0;
    self.containerLayer.thirdRadius = 0;
    
    [self.containerLayer addAnimation:[self getBounceAnimationForKey:@"firstRadius" withBeginTime:0.0f] forKey:nil];
    [self.containerLayer addAnimation:[self getBounceAnimationForKey:@"secondRadius" withBeginTime:0.2f] forKey:nil];
    [self.containerLayer addAnimation:[self getBounceAnimationForKey:@"thirdRadius" withBeginTime:0.4f] forKey:nil];
}

- (CAAnimation*)getBounceAnimationForKey:(NSString *)keyPath withBeginTime:(CFTimeInterval)beginTime
{
    CAKeyframeAnimation *circleAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    circleAnimation.repeatCount = INFINITY;
    circleAnimation.duration = 2.2f;
    circleAnimation.beginTime = CACurrentMediaTime() + beginTime;
    
    CAMediaTimingFunction *cubicEaseOut = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.16f :0.75f :0.42f];
    CAMediaTimingFunction *cubicEaseIn = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.5f :0.75f :0.87f];
    circleAnimation.timingFunctions = @[
                                        cubicEaseOut,
                                        cubicEaseIn,
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                        cubicEaseOut,
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]
                                        ];
    circleAnimation.values = @[@0, @1.0, @0.75, @0.75, @0, @0];
    circleAnimation.keyTimes = @[@0, @0.12, @0.22, @0.72, @0.8, @1.0];
    return circleAnimation;
}

- (void)setColor:(UIColor *)color
{
    self.containerLayer.color = [color CGColor];
}

- (UIColor *)color
{
    return [UIColor colorWithCGColor:self.containerLayer.color];
}

@end
