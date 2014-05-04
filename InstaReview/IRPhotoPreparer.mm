//
//  IRPhotoPreparer.m
//  InstaReview
//
//  Created by Max Medvedev on 4/16/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRPhotoPreparer.h"
#import "BookCropper.h"
#import "UIImage+Resize.h"
#import "UIImage+Filters.h"

@implementation IRPhotoPreparer

- (UIImage*)prepareImageForRecognition:(UIImage *)sourceImage
{
    UIImage *resizedImage = [sourceImage resizedImage:CGSizeMake(480, 640)
                                 interpolationQuality:kCGInterpolationLow];
    cv::Mat source = [IRPhotoPreparer cvMatFromUIImage:resizedImage];
    BookCropper cropper;
    cv::Mat croppedImage = cropper.getBookImage(source);
    
    // applying filters
    UIImage *newImage = [IRPhotoPreparer UIImageFromCVMat:croppedImage];
    return newImage;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if ( cvMat.elemSize() == 1 ) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData( (__bridge CFDataRef)data );
    CGImageRef imageRef = CGImageCreate( cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease( imageRef );
    CGDataProviderRelease( provider );
    CGColorSpaceRelease( colorSpace );
    return finalImage;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace( image.CGImage );
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat( rows, cols, CV_8UC4 );
    CGContextRef contextRef = CGBitmapContextCreate( cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault );
    CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
    CGContextRelease( contextRef );
    CGColorSpaceRelease( colorSpace );
    return cvMat;
}

@end
