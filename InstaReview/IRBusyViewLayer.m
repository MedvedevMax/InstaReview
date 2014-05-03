//
//  IRBusyViewLayer.m
//  InstaReview
//
//  Created by Max Medvedev on 5/2/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBusyViewLayer.h"

@implementation IRBusyViewLayer

@synthesize color = _color;

- (void)setColor:(CGColorRef)color
{
    CGColorRelease(_color);
    CGColorRetain(color);
    _color = color;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"firstRadius"] ||
        [key isEqualToString:@"secondRadius"] ||
        [key isEqualToString:@"thirdRadius"] ||
        [key isEqualToString:@"color"]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    
    if (self) {
        if ([layer isKindOfClass:[IRBusyViewLayer class]]) {
            IRBusyViewLayer *copyLayer = layer;
            
            self.color = copyLayer.color;
            self.firstRadius = copyLayer.firstRadius;
            self.secondRadius = copyLayer.secondRadius;
            self.thirdRadius = copyLayer.thirdRadius;
        }
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    #define INTERVAL_SIZE 5.0f
    
    CGFloat cellWidth = self.bounds.size.width / 3.0;
    CGFloat maxArcSize = MIN(cellWidth - INTERVAL_SIZE, self.bounds.size.height);
    
    CGFloat xCenter_1 = 0 * cellWidth + (cellWidth / 2) + (1 - self.firstRadius) * cellWidth * 0.6;
    CGFloat xCenter_2 = 1 * cellWidth + (cellWidth / 2);
    CGFloat xCenter_3 = 2 * cellWidth + (cellWidth / 2) - (1 - self.thirdRadius) * cellWidth * 0.6;
    CGFloat yCenter = self.bounds.size.height / 2;
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, self.color);
    
    [self putEllipseToContext:context at:CGPointMake(xCenter_1, yCenter) withRadius:(self.firstRadius * maxArcSize / 2)];
    [self putEllipseToContext:context at:CGPointMake(xCenter_2, yCenter) withRadius:(self.secondRadius * maxArcSize / 2)];
    [self putEllipseToContext:context at:CGPointMake(xCenter_3, yCenter) withRadius:(self.thirdRadius * maxArcSize / 2)];
}

- (void)putEllipseToContext:(CGContextRef)context at:(CGPoint)center withRadius:(CGFloat)radius
{
    if (!radius) {
        return;
    }
    
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, NO);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

@end
