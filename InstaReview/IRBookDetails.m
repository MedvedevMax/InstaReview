//
//  IRBookDetails.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookDetails.h"
#import "IRBookReview.h"

@implementation IRBookDetails

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.name = dic[@"name"];
        self.author = dic[@"author"];
        self.coverUrl = dic[@"coverUrl"];
        self.url = dic[@"url"];
        self.rating = dic[@"rating"];
        self.published = dic[@"publish"];
        self.description = dic[@"description"];
        
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
