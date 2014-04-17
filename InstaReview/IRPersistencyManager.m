//
//  IRPersistencyManager.m
//  InstaReview
//
//  Created by Max Medvedev on 4/18/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRPersistencyManager.h"

@interface IRPersistencyManager ()

@property (nonatomic, retain) NSMutableArray *viewedBooks;

@end

@implementation IRPersistencyManager

- (void)addBookToViewed:(IRBookDetails *)book
{
    for (IRBookDetails *viewedBook in self.viewedBooks) {
        if ([book.name isEqualToString:viewedBook.name] &&
            [book.author isEqualToString:viewedBook.author]) {
            // found duplicate
            return;
        }
    }
    
    [self.viewedBooks addObject:book];
}

- (NSArray*)getAllViewedBooks
{
    return [self.viewedBooks copy];
}

@end
