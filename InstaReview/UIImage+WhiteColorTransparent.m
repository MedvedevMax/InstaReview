//
//  UIImage+WhiteColorTransparent.m
//  InstaReview
//
//  Created by Max Medvedev on 4/19/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "UIImage+WhiteColorTransparent.h"

@implementation UIImage (WhiteColorTransparent)

- (UIImage *)makeWhiteColorTransparent
{
    CGImageRef rawImageRef = self.CGImage;
    const CGFloat colorMasking[6] = {230, 255, 230, 255, 230, 255};
    UIGraphicsBeginImageContext(self.size);
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, self.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height), maskedImageRef);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
