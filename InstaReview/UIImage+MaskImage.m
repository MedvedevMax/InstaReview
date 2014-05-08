//
//  UIImage+MaskImage.m
//  InstaReview
//
//  Created by Max Medvedev on 5/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "UIImage+MaskImage.h"

@implementation UIImage (MaskImage)

+ (UIImage *)blankImageWithSize:(CGSize)size scale:(CGFloat)scale
{
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width )>1))

- (CGImageRef)ellipseMask
{
    CGFloat imageScale = (CGFloat)1.0;
    CGFloat width = (CGFloat)174.0;
    CGFloat height = (CGFloat)174.0;
    CGFloat radius = (CGFloat)86.0;
    
    if (HIRESDEVICE) {
        imageScale = (CGFloat)2.0;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width * imageScale, height * imageScale, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    // Drawing
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, width * imageScale / 2, height * imageScale / 2, radius * imageScale, 0, 2 * M_PI, NO);
    CGContextFillPath(context);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return cgImage;
}

- (UIImage*)applyEllipseMask
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGImageRef maskImageRef = [self ellipseMask];
    CGSize maskImageSize = { CGImageGetWidth(maskImageRef), CGImageGetHeight(maskImageRef) };
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate(NULL, maskImageSize.width, maskImageSize.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGFloat ratio = 0;
    ratio = maskImageSize.width / self.size.width;
    
    if (ratio * self.size.height < maskImageSize.height) {
        ratio = maskImageSize.height/ self.size.height;
    }
    
    CGRect rect1 = {{0, 0}, {maskImageSize.width, maskImageSize.height}};
    CGRect rect2 = {{-((self.size.width*ratio)-maskImageSize.width)/2 , -((self.size.height*ratio)-maskImageSize.height)/2}, {self.size.width*ratio, self.size.height*ratio}};
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, self.CGImage);
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}

@end
