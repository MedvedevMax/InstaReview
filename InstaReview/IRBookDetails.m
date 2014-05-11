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

        self.rating = @([[self zeroStringOrValue:dic[@"rating"]] floatValue]);
        self.ratingCount = @([[self zeroStringOrValue:dic[@"ratingCount"]] intValue]);
        
        self.year = @([[self zeroStringOrValue:dic[@"year"]] intValue]);
        
        self.price = [self emptyStringOrValue:dic[@"price"]];
        self.url = [self emptyStringOrValue:dic[@"url"]];
        
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.alternativeName = [aDecoder decodeObjectForKey:@"altname"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.description = [aDecoder decodeObjectForKey:@"description"];
        self.rating = [aDecoder decodeObjectForKey:@"rating"];
        self.ratingCount = [aDecoder decodeObjectForKey:@"ratingCount"];
        self.year = [aDecoder decodeObjectForKey:@"year"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.coverUrl = [aDecoder decodeObjectForKey:@"coverUrl"];
        self.coverImage = [aDecoder decodeObjectForKey:@"coverImage"];
        self.reviews = [aDecoder decodeObjectForKey:@"reviews"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.alternativeName forKey:@"altname"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.description forKey:@"description"];
    [aCoder encodeObject:self.rating forKey:@"rating"];
    [aCoder encodeObject:self.ratingCount forKey:@"ratingCount"];
    [aCoder encodeObject:self.year forKey:@"year"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.coverUrl forKey:@"coverUrl"];
    [aCoder encodeObject:self.coverImage forKey:@"coverImage"];
    [aCoder encodeObject:self.reviews forKey:@"reviews"];
}

@end
