//
//  IRReviewsFetcher.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRReviewsFetcher : NSObject

- (NSArray*)getBooksForCoverPhotoUrl:(NSString *)imageUrl;

@end
