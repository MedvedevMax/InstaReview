//
//  IRRecognitionSession.h
//  InstaReview
//
//  Created by Max Medvedev on 3/29/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRRecognitionResponse.h"

@interface IRRecognitionSession : NSObject

- (void)pushPhoto:(UIImage *)image;
- (NSArray*)waitAndGetReviews;

@end
