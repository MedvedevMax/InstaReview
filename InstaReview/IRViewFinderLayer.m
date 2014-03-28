//
//  IRViewFinderLayer.m
//  InstaReview
//
//  Created by Max Medvedev on 3/28/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRViewFinderLayer.h"

@implementation IRViewFinderLayer

#define ANGLE_DIFF M_PI / 24
#define MIN_ACTUAL_RADIUS 45.0f
#define PEN_THICKNESS 3.0

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"radius"] || [key isEqualToString:@"color"]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    
    if (self) {
    if ([layer isKindOfClass:[IRViewFinderLayer class]]) {
        IRViewFinderLayer *copyLayer = layer;
        
        self.color = copyLayer.color;
        self.radius = copyLayer.radius;
    }
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, PEN_THICKNESS);
    CGContextSetStrokeColorWithColor(context, self.color);
    
    CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2,
                                 self.bounds.origin.y + self.bounds.size.height / 2);
    
    CGFloat size = self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width : self.bounds.size.height;
    CGFloat radius = MIN_ACTUAL_RADIUS + self.radius * (size / 2.0f - MIN_ACTUAL_RADIUS);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, ANGLE_DIFF, M_PI_2 - ANGLE_DIFF, NO);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, M_PI_2 + ANGLE_DIFF, M_PI - ANGLE_DIFF, NO);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, M_PI + ANGLE_DIFF, 3 * M_PI_2 - ANGLE_DIFF, NO);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, 3 * M_PI_2 + ANGLE_DIFF, 2 * M_PI -ANGLE_DIFF, NO);
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 4);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, 2, 0, 2 * M_PI, YES);
    CGContextStrokePath(context);
}

@end
