//
//  UIImage+Filters.m
//  InstaReview
//
//  Created by Max Medvedev on 3/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)

- (UIImage *)imageWithGamma:(double)gamma andSharpen:(double)sharpness
{
    CIImage *image = [[CIImage alloc] initWithImage:self];

    CIFilter *shadowFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
    [shadowFilter setValue:image forKey:kCIInputImageKey];
    [shadowFilter setValue:@(0.5) forKey:@"inputPower"];
    
    CIFilter *sharpFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [sharpFilter setValue:[shadowFilter valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
    [sharpFilter setValue:@(sharpness) forKey:kCIInputSharpnessKey];
    
    CIImage *result = [sharpFilter valueForKey:kCIOutputImageKey];

    // saving to CGImage -> UIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    return [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
}

@end
