//
//  UIImage+drawImage.m
//  InstaReview
//
//  Created by Max Medvedev on 5/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "UIImage+drawImage.h"

@implementation UIImage (DrawImage)

- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
    [inputImage drawInRect:frame];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
