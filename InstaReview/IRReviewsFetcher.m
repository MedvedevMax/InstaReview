//
//  IRReviewsFetcher.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsFetcher.h"
#import "IRBookDetails.h"

#define IR_API_URL @"http://instareview-medvedev.rhcloud.com/1.1/"
//#define IR_API_URL @"http://localhost:8888/1.0/"

@implementation IRReviewsFetcher

- (NSArray*)getBooksForCoverPhotoUrl:(NSString *)imageUrl
{
    NSURL *queryUrl = [NSURL URLWithString:
                       [NSString stringWithFormat:@"%@?imgurl=%@",
                        IR_API_URL, [self encodeURL:imageUrl]]];
    
    NSLog(@"Querying API at %@", queryUrl);
    NSData *apiResponse = [NSData dataWithContentsOfURL:queryUrl];
    if (!apiResponse) {
        NSLog(@"Can't get the response");
        return nil;
    }
    
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:apiResponse options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error parsing jQuery: %@", error);
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Response is not dictionary");
        return nil;
    }
    
    NSString *response = [dictionary objectForKey:@"response"];
    NSArray *bookDics = [dictionary objectForKey:@"reviews"];
    
    if (![response isEqualToString:@"success"]) {
        NSLog(@"Query failed (response = %@)", response);
        return nil;
    }
    
    if (![bookDics isKindOfClass:[NSArray class]]) {
        NSLog(@"[Reviews] content is not an array");
        return nil;
    }
    
    NSMutableArray *books = [[NSMutableArray alloc] init];
    
    for (NSDictionary *bookDic in bookDics) {
        [books addObject:[[IRBookDetails alloc] initWithDictionary:bookDic]];
    }
    
    return [books copy];
}

- (NSString*)encodeURL:(NSString *)unescaped
{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
