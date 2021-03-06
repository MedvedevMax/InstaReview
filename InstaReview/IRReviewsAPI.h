//
//  IRReviewsAPI.h
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRBookDetails.h"

@interface IRReviewsAPI : NSObject

+ (id)sharedInstance;

- (void)beginGettingBooksForPhoto:(UIImage *)photo;
- (NSArray*)waitAndGetBooks;

- (void)addBookToViewed:(IRBookDetails *)book;
- (void)removeBookFromViewed:(IRBookDetails *)book;
- (NSArray*)getAllViewedBooks;
- (void)saveViewedBooksHistory;

- (void)downloadCoverForBook:(IRBookDetails *)book;

@end
