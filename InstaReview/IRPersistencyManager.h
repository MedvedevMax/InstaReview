//
//  IRPersistencyManager.h
//  InstaReview
//
//  Created by Max Medvedev on 4/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRBookDetails.h"

@interface IRPersistencyManager : NSObject

- (void)addBookToViewed:(IRBookDetails *)book;
- (NSArray*)getAllViewedBooks;

- (void)saveHistory;

@end
