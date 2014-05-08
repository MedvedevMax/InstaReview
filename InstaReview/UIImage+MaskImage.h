//
//  UIImage+MaskImage.h
//  InstaReview
//
//  Created by Max Medvedev on 5/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MaskImage)

+ (UIImage*)blankImageWithSize:(CGSize)size scale:(CGFloat)scale;

- (UIImage*)applyEllipseMask;

@end
