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
        self.identifier = @([[self zeroStringOrValue:dic[@"identifier"]] intValue]);
        
        self.name = [self emptyStringOrValue:dic[@"name"]];
        self.alternativeName = [self emptyStringOrValue:dic[@"altname"]];
        self.author = [self emptyStringOrValue:dic[@"author"]];
        
        self.description = [self emptyStringOrValue:dic[@"description"]];

        self.rating = @([[self zeroStringOrValue:dic[@"rating"]] doubleValue]);
        self.ratingCount = @([[self zeroStringOrValue:dic[@"ratingCount"]] intValue]);
        
        self.year = @([[self zeroStringOrValue:dic[@"year"]] intValue]);
        
        self.coverUrl = [self emptyStringOrValue:dic[@"coverUrl"]];
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

- (NSString *)zeroStringOrValue:(id)dictionaryObject
{
    return [dictionaryObject isKindOfClass:[NSNull class]] ? @"0" : dictionaryObject;
}

@end
