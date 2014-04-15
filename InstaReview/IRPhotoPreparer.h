//
//  IRPhotoPreparer.h
//  InstaReview
//
//  Created by Max Medvedev on 4/16/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRPhotoPreparer : NSObject

- (UIImage*)prepareImageForRecognition:(UIImage *)sourceImage;

@end
