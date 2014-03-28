//
//  IRReviewsAPI.h
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRBookDetails.h"
#import "IRRecognitionSession.h"

@interface IRReviewsAPI : NSObject

+ (id)sharedInstance;

- (IRRecognitionSession*)newSession;
- (void)downloadCoverForBook:(IRBookDetails *)book;

@end
