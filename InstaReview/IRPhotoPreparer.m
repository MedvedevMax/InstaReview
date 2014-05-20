//
//  IRPhotoPreparer.m
//  InstaReview
//
//  Created by Max Medvedev on 4/16/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRPhotoPreparer.h"
#import "UIImage+Resize.h"
#import "UIImage+Filters.h"

@implementation IRPhotoPreparer

- (UIImage*)prepareImageForRecognition:(UIImage *)sourceImage
{
    #define CUT_FRAME_X         160 / 320.0
    #define CUT_FRAME_Y         234 / 480.0
    
    #define CUT_FRAME_WIDTH     220 / 320.0 - 0.05
    #define CUT_FRAME_HEIGHT    327 / 480.0 + 0.1

    #define IMAGE_RESIZE_WIDTH  252
    #define IMAGE_RESIZE_HEIGHT 336
    
    UIImage *resizedImage = [sourceImage resizedImage:CGSizeMake(IMAGE_RESIZE_WIDTH,
                                                                 IMAGE_RESIZE_HEIGHT)
                                 interpolationQuality:kCGInterpolationMedium];
    
    CGRect cropFrame = CGRectMake((CUT_FRAME_X - (CUT_FRAME_WIDTH) / 2) * IMAGE_RESIZE_WIDTH,
                                  (CUT_FRAME_Y - (CUT_FRAME_HEIGHT) / 2) * IMAGE_RESIZE_HEIGHT,
                                  (CUT_FRAME_WIDTH) * IMAGE_RESIZE_WIDTH,
                                  (CUT_FRAME_HEIGHT) * IMAGE_RESIZE_HEIGHT);
    UIImage *newImage = [resizedImage croppedImage:cropFrame];
    return newImage;
}

@end
