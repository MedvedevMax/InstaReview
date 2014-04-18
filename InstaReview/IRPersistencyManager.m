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

@property (nonatomic, strong, readonly) NSString *historyFileName;
@end

@implementation IRPersistencyManager

- (id)init
{
    self = [super init];
    
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:self.historyFileName];
        self.viewedBooks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!self.viewedBooks) {
            self.viewedBooks = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)addBookToViewed:(IRBookDetails *)book
{
    IRBookDetails *duplicate = nil;
    for (IRBookDetails *viewedBook in self.viewedBooks) {
        if ([book.name isEqualToString:viewedBook.name] &&
            [book.author isEqualToString:viewedBook.author]) {
            duplicate = viewedBook;
            break;
        }
    }
    
    if (duplicate) {
        // remove duplicate to put new one to top
        [self.viewedBooks removeObject:duplicate];
    }
    
    [self.viewedBooks insertObject:book atIndex:0];
}

- (void)removeBookFromViewed:(IRBookDetails *)book
{
    [self.viewedBooks removeObject:book];
}

- (NSArray*)getAllViewedBooks
{
    return [self.viewedBooks copy];
}

- (void)saveHistory
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.viewedBooks];
    [data writeToFile:self.historyFileName atomically:YES];
}

- (NSString*)historyFileName
{
    return [NSHomeDirectory() stringByAppendingString:@"/Documents/viewedBooks.bin"];
}

@end
