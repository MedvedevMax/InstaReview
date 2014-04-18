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
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(self.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, self.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

@end
