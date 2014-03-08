//
//  IRBookDetails.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookDetails.h"
#import "IRBookReview.h"

#import "IRReviewsAPI.h"

@implementation IRBookDetails

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.name = dic[@"name"];
        self.author = dic[@"author"];
        self.coverUrl = dic[@"coverUrl"];
        self.url = dic[@"url"];

        if (![dic[@"rating"] isKindOfClass:[NSNull class]]) {
            self.rating = @([dic[@"rating"] doubleValue]);
        }
        else {
            self.rating = 0;
        }
        
        self.published = dic[@"publish"];
        self.description = dic[@"description"];
        
        self.coverImage = nil;
        
        NSArray *reviewsDicArray = dic[@"reviews"];
        NSMutableArray *reviews = [[NSMutableArray alloc] init];
        for (NSDictionary *review in reviewsDicArray) {
            [reviews addObject:[[IRBookReview alloc] initWithDictionary:review]];
        }
        
        self.reviews = [reviews copy];
    }
    
    return self;
}

@end
