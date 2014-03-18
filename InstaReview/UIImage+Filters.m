//
//  UIImage+Filters.m
//  InstaReview
//
//  Created by Max Medvedev on 3/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)

- (UIImage *)processImageForRecognition
{
    #define IMG_GAMMA                   0.6f
    #define IMG_SHARPNESS               0.65f
    #define IMG_SATURATION              1.3f
    #define IMG_CONTRAST                1.2f
    
    CIImage *image = [[CIImage alloc] initWithImage:self];

    CIFilter *shadowFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
    [shadowFilter setDefaults];
    [shadowFilter setValue:image forKey:kCIInputImageKey];
    [shadowFilter setValue:@(IMG_GAMMA) forKey:@"inputPower"];
    
    CIFilter *sharpFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [sharpFilter setDefaults];
    [sharpFilter setValue:[shadowFilter valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
    [sharpFilter setValue:@(IMG_SHARPNESS) forKey:kCIInputSharpnessKey];
    
    CIFilter *saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
    [saturationFilter setDefaults];
    [saturationFilter setValue:[sharpFilter valueForKey:kCIOutputImageKey] forKey:@"inputImage"];
    [saturationFilter setValue:@(IMG_SATURATION) forKey:@"inputSaturation"];
    [saturationFilter setValue:@(IMG_CONTRAST) forKey:@"inputContrast"];
    
    CIImage *result = [saturationFilter valueForKey:kCIOutputImageKey];

    // saving to CGImage -> UIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    return [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
}

@end
