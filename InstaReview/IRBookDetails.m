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
        self.name = [self emptyStringOrValue:dic[@"name"]];
        self.author = [self emptyStringOrValue:dic[@"author"]];
        self.coverUrl = [self emptyStringOrValue:dic[@"coverUrl"]];
        self.url = [self emptyStringOrValue:dic[@"url"]];

        if (![dic[@"rating"] isKindOfClass:[NSNull class]]) {
            self.rating = @([dic[@"rating"] doubleValue]);
        }
        else {
            self.rating = 0;
        }
        
        self.published = [self emptyStringOrValue:dic[@"publish"]];
        self.description = [self emptyStringOrValue:dic[@"description"]];
        
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

- (NSString *)emptyStringOrValue:(id)dictionaryObject
{
    return [dictionaryObject isKindOfClass:[NSNull class]] ? @"" : dictionaryObject;
}

@end
